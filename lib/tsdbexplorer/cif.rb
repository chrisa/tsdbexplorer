#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
#
#  TSDBExplorer is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
#  Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with TSDBExplorer.  If not, see <http://www.gnu.org/licenses/>.
#
#  $Id$
#

require 'tsdbexplorer/tdnet.rb'
require 'tsdbexplorer/cif/classes.rb'

module TSDBExplorer

  module CIF

    # Process a record from a CIF file and return the data as a Hash

    def CIF.parse_record(record)

      result = Hash.new
      result[:record_identity] = record[0..1]

      # Process the record using the built-in Class parser

      if result[:record_identity] == "HD"
        result = TSDBExplorer::CIF::HeaderRecord.new(record)
      elsif result[:record_identity] == "BS"
        result = TSDBExplorer::CIF::BasicScheduleRecord.new(record)
      elsif result[:record_identity] == "BX"
        result = TSDBExplorer::CIF::BasicScheduleExtendedRecord.new(record)
      elsif result[:record_identity] == "TI" || result[:record_identity] == "TA" || result[:record_identity] == "TD"
        result = TSDBExplorer::CIF::TiplocRecord.new(record)
      elsif result[:record_identity] == "LO" || result[:record_identity] == "LI" || result[:record_identity] == "LT"
        result = TSDBExplorer::CIF::LocationRecord.new(record)
      elsif result[:record_identity] == "AA"
        result = TSDBExplorer::CIF::AssociationRecord.new(record)
      elsif result[:record_identity] == "CR"
        result = TSDBExplorer::CIF::ChangeEnRouteRecord.new(record)
      elsif result[:record_identity] == "ZZ"
        # End of File
      else
        raise "Unsupported record type '#{result[:record_identity]}'"
      end

      return result

    end


    # Process a CIF file

    def CIF.process_cif_file(filename)

      cif_data = File.open(filename)
      file_size = File.size(filename)
      puts "\n"
      puts "Processing #{filename} (#{file_size} bytes)"


      # The first line of the CIF file must be an HD record

      header_data = TSDBExplorer::CIF::parse_record(cif_data.first)
      raise "Expecting an HD record at the start of #{filename} - found a '#{header_data[:record_identity]}' record" unless header_data.is_a? TSDBExplorer::CIF::HeaderRecord


      # Display data from the CIF header record

      puts "+--------------------------------------------------------------------------"
      puts "| Importing CIF file #{header_data.current_file_ref} for #{header_data.mainframe_username}"
      puts "| Generated on #{header_data.date_of_extract} at #{header_data.time_of_extract}"
      puts "| Data from #{header_data.user_extract_start_date} to #{header_data.user_extract_end_date}"
      puts "+--------------------------------------------------------------------------"


      # Initialize a set of statistics to return to the calling function

      stats = {:schedule=>{:insert=>0, :amend=>0, :delete=>0}, :tiploc=>{:insert=>0, :amend=>0, :delete=>0}, :association=>{:insert=>0, :amend=>0, :delete=>0}}

      pending = { 'Tiploc' => { :cols => [ :tiploc_code, :nalco, :tps_description, :stanox, :crs_code, :description ], :rows => [] },
                  'BasicSchedule' => { :cols => [ :uuid, :train_uid, :train_identity_unique, :runs_from, :runs_to, :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa, :runs_su, :bh_running, :status, :category, :train_identity, :headcode, :service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :train_class, :sleepers, :reservations, :catering_code, :service_branding, :stp_indicator, :uic_code, :atoc_code, :ats_code, :rsid, :data_source ], :rows => [] },
                  'Location' => { :cols => [ :basic_schedule_uuid, :location_type, :seq, :tiploc_code, :tiploc_instance, :arrival, :public_arrival, :pass, :departure, :public_departure, :platform, :line, :path, :engineering_allowance, :pathing_allowance, :performance_allowance, :activity ], :rows => [] } }

      start_time = Time.now


      # Set up a progress bar

      require 'progressbar' # TODO: Eliminate having to 'require' progressbar
      pbar = ProgressBar.new(header_data.current_file_ref, file_size)


      # Iterate through the CIF file and process each record

      while(!cif_data.eof)

        record = TSDBExplorer::CIF::parse_record(cif_data.gets)

        pbar.set(cif_data.pos)

        if record.is_a? TSDBExplorer::CIF::TiplocRecord

          if record.action == "I"

            # TIPLOC Insert

            data = []
            pending['Tiploc'][:cols].each do |column|
              data << record.send(column)
            end
            pending['Tiploc'][:rows] << data

            stats[:tiploc][:insert] = stats[:tiploc][:insert] + 1

          elsif record.action == "A"

            # TIPLOC Amend

            raise "TIPLOC Amend record not allowed in a full extract" if header_data.update_indicator == "F"

            amend_record = Tiploc.find_by_tiploc_code(record.tiploc_code)
            raise "Unknown TIPLOC '#{record.tiploc_code}' found in TA record" if amend_record.nil?

            [ :tiploc_code, :nalco, :tps_description, :stanox, :crs_code, :description ].each do |field|
              amend_record[field] = record.send(field)
            end

            amend_record.save

            stats[:tiploc][:amend] = stats[:tiploc][:amend] + 1

          elsif record.action == "D"

            # TIPLOC Delete

            raise "TIPLOC Delete record not allowed in a full extract" if header_data.update_indicator == "F"

            deletion_record = Tiploc.find_by_tiploc_code(record.tiploc_code)
            raise "Unknown TIPLOC '#{record.tiploc_code}' found in TD record" if deletion_record.nil?
            deletion_record.destroy

            stats[:tiploc][:delete] = stats[:tiploc][:delete] + 1

          end

        elsif record.is_a? TSDBExplorer::CIF::BasicScheduleRecord

          # Check if we have any pending TIPLOCs to insert, and if so,
          # process them now

          pending = process_pending(pending) if pending['Tiploc'][:rows].count > 0


          # If we are processing a Revise record, delete the schedule to
          # which the revision applies, change the transaction type to New
          # and process normally

          if record.transaction_type == "R"

            raise "Basic Schedule 'revise' record not allowed in a full extract" if header_data.update_indicator == "F"

            deletion_record = BasicSchedule.find(:first, :conditions => { :train_uid => record.train_uid, :runs_from => record.runs_from })
            raise "Unknown schedule for UID #{record[:train_uid]} on #{record[:runs_from]}" if deletion_record.nil?

            deletion_record.destroy

          end


          loc_records = Array.new

          if record.transaction_type == "N" || record.transaction_type == "R"

            # Schedule cancellations (BS records with the STP indicator set to
            # 'C') have no locations, so must be processed separately

            bs_record = Hash.new

            if record.stp_indicator != "C"

              # Generate a UUID  for this BasicSchedule record

              uuid = UUID.generate
              record.uuid = uuid


              # Read in the associated BX record and merge the data in to the BS record

              bx_record = TSDBExplorer::CIF::parse_record(cif_data.gets)
              record.merge_bx_record(bx_record)


              # Read in all records up to and including the next LT record

              location_record = TSDBExplorer::CIF::LocationRecord.new

              seq = 10

              while(1)

                cif_record = cif_data.gets
                next if cif_record[0..1] == "CR" # TODO: Remove change-en-route hack
                location_record = TSDBExplorer::CIF::parse_record(cif_record)
                location_record.seq = seq
                raise "Record was parsed as a '#{location_record.class}', expecting a TSDBExplorer::CIF::LocationRecord" unless location_record.is_a? TSDBExplorer::CIF::LocationRecord
                location_record.basic_schedule_uuid = uuid
                loc_records << location_record

                break if location_record.location_type == "LT"

                seq = seq + 10

              end

              if record.transaction_type == "N"
                stats[:schedule][:insert] = stats[:schedule][:insert] + 1
              else
                stats[:schedule][:amend] = stats[:schedule][:amend] + 1
              end

            end

          elsif record.transaction_type == "D"

            raise "Basic Schedule 'delete' record not allowed in a full extract" if header_data.update_indicator == "F"

            deletion_record = BasicSchedule.find(:first, :conditions => { :train_uid => record.train_uid, :runs_from => record.runs_from })
            raise "Unknown schedule for UID #{record[:train_uid]} on #{record[:runs_from]}" if deletion_record.nil?

            deletion_record.destroy

            stats[:schedule][:delete] = stats[:schedule][:delete] + 1

          else

            raise "Unknown BS transaction type #{record[:transaction_type]}"

          end



          # If location records exist for this schedule (as they might not
          # if this is a cancellation), push them on to the pending INSERT
          # queue

          unless loc_records == []

            loc_records.each do |r|
              data = []
              pending['Location'][:cols].each do |column|
                data << r.send(column) if r.respond_to? column
              end
              pending['Location'][:rows] << data
            end

          end


          # Push any the schedules on to the pending INSERT queue

          if bs_record

            data = []
            pending['BasicSchedule'][:cols].each do |column|
              data << record.send(column) if record.respond_to? column
            end

            pending['BasicSchedule'][:rows] << data

            if pending['BasicSchedule'][:rows].count > 1000
              pending = process_pending(pending)
            end

          end

        end

      end

      pbar.finish

      pending = process_pending(pending)

      return stats

    end


    def CIF.process_pending(pending)

      # Process all the pending transactions

      pending.keys.each do |model_object|

        Rails.logger.silence do
          eval(model_object).import pending[model_object][:cols], pending[model_object][:rows], :validate => false
        end

        pending[model_object][:rows] = []

      end

      return pending

    end


    # Convert an origin time to an origin code, used to construct a
    # 10-character Unique Train Identity

    def CIF.departure_to_code(time)

      hour = time[0..1].to_i
      minute = time[2..3].to_i
      offset = hour * 2 + (minute / 30)

      xlate = "00112233445566ABCDEFGHIJKLMNOPQRSTUVWXYYZZ778899".split(//)

      return xlate[offset]

    end


    # Calculate the next mainframe file reference, given the last processed

    def CIF.next_file_reference(last_file)

      next_file = nil

      if last_file[-1..-1] == "Z"
        next_file = last_file[0..5] + "A"
      else
        next_file = last_file.next
      end

    end

  end

end
