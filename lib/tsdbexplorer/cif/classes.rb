#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software@ you can redistribute it and/or modify it
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
#  with TSDBExplorer.  If not, see <http@//www.gnu.org/licenses/>.
#
#  $Id$
#

module TSDBExplorer

  module CIF

    class HeaderRecord

      FIELDS = [ :file_mainframe_identity, :date_of_extract, :time_of_extract, :current_file_ref, :last_file_ref, :update_indicator, :version, :user_extract_start_date, :user_extract_end_date, :mainframe_username, :extract_date ]

      attr_reader :file_mainframe_identity, :date_of_extract, :time_of_extract, :current_file_ref, :last_file_ref, :update_indicator, :version, :user_extract_start_date, :user_extract_end_date, :mainframe_username, :extract_date
      attr_accessor :file_mainframe_identity, :date_of_extract, :time_of_extract, :current_file_ref, :last_file_ref, :update_indicator, :version, :user_extract_start_date, :user_extract_end_date, :mainframe_username, :extract_date

      def initialize(record=nil)

        if record

          self.file_mainframe_identity = record[2..21]
          self.date_of_extract = record[22..27]
          self.time_of_extract = record[28..31]
          self.current_file_ref = record[32..38]
          self.last_file_ref = record[39..45]
          self.update_indicator = record[46..46]
          self.version = record[47..47]
          self.user_extract_start_date = record[48..53]
          self.user_extract_end_date = record[54..59]

          raise "Mainframe identity is not valid" unless self.file_mainframe_identity.match(/TPS.U(.{6}).PD(.{6})/)
          self.mainframe_username = $1
          self.extract_date = $2

        end

      end

    end

    class TiplocRecord

      FIELDS = [ :action, :tiploc_code, :new_tiploc, :nalco, :nalco_four, :tps_description, :stanox, :crs_code, :description ]

      attr_reader :action, :tiploc_code, :new_tiploc, :nalco, :nalco_four, :tps_description, :stanox, :crs_code, :description
      attr_accessor :action, :tiploc_code, :new_tiploc, :nalco, :nalco_four, :tps_description, :stanox, :crs_code, :description

      def initialize(record=nil)

        if record

          self.action = record[1..1]
          self.tiploc_code = record[2..8].strip
          self.nalco = record[11..16]
          self.nalco_four = record[11..14]
          self.tps_description = record[18..43]
          self.stanox = record[44..48]
          self.crs_code = record[53..55]
          self.description = record[56..72]
          self.new_tiploc = record[73..77] if self.action == "A"

          self.description = self.description.strip.empty? ? nil : self.description.strip unless self.description.nil?
          self.tps_description = self.tps_description.strip.empty? ? nil : self.tps_description.strip unless self.tps_description.nil?

          self.stanox = nil if self.stanox == "00000"

        end

      end

    end

    class LocationRecord

      FIELDS = [ :basic_schedule_uuid, :record_identity, :location_type, :seq, :tiploc_code, :tiploc_instance, :arrival, :public_arrival, :pass, :departure, :public_departure, :platform, :line, :path, :engineering_allowance, :pathing_allowance, :performance_allowance, :activity_ae, :activity_bl, :activity_minusd, :activity_hh, :activity_kc, :activity_ke, :activity_kf, :activity_ks, :activity_op, :activity_or, :activity_pr, :activity_rm, :activity_rr, :activity_minust, :activity_tb, :activity_tf, :activity_ts, :activity_tw, :activity_minusu, :activity_a, :activity_c, :activity_d, :activity_e, :activity_g, :activity_h, :activity_k, :activity_l, :activity_n, :activity_r, :activity_s, :activity_t, :activity_u, :activity_w, :activity_x, :next_day_arrival, :next_day_departure, :arrival_secs, :departure_secs, :pass_secs, :public_arrival_secs, :public_departure_secs ]

      attr_reader :basic_schedule_uuid, :record_identity, :location_type, :seq, :tiploc_code, :tiploc_instance, :arrival, :public_arrival, :pass, :departure, :public_departure, :platform, :line, :path, :engineering_allowance, :pathing_allowance, :performance_allowance, :activity_ae, :activity_bl, :activity_minusd, :activity_hh, :activity_kc, :activity_ke, :activity_kf, :activity_ks, :activity_op, :activity_or, :activity_pr, :activity_rm, :activity_rr, :activity_minust, :activity_tb, :activity_tf, :activity_ts, :activity_tw, :activity_minusu, :activity_a, :activity_c, :activity_d, :activity_e, :activity_g, :activity_h, :activity_k, :activity_l, :activity_n, :activity_r, :activity_s, :activity_t, :activity_u, :activity_w, :activity_x, :next_day_arrival, :next_day_departure, :arrival_secs, :departure_secs, :pass_secs, :public_arrival_secs, :public_departure_secs
      attr_accessor :basic_schedule_uuid, :record_identity, :location_type, :seq, :tiploc_code, :tiploc_instance, :arrival, :public_arrival, :pass, :departure, :public_departure, :platform, :line, :path, :engineering_allowance, :pathing_allowance, :performance_allowance, :activity_ae, :activity_bl, :activity_minusd, :activity_hh, :activity_kc, :activity_ke, :activity_kf, :activity_ks, :activity_op, :activity_or, :activity_pr, :activity_rm, :activity_rr, :activity_minust, :activity_tb, :activity_tf, :activity_ts, :activity_tw, :activity_minusu, :activity_a, :activity_c, :activity_d, :activity_e, :activity_g, :activity_h, :activity_k, :activity_l, :activity_n, :activity_r, :activity_s, :activity_t, :activity_u, :activity_w, :activity_x, :next_day_arrival, :next_day_departure, :arrival_secs, :departure_secs, :pass_secs, :public_arrival_secs, :public_departure_secs

      def initialize(record=nil)

        if record

          self.location_type = record[0..1]
          self.record_identity = self.location_type
          self.tiploc_code = record[2..8].strip
          self.tiploc_instance = record[9..9]
          activity_list = nil

          if self.location_type == "LO"
            self.departure = record[10..14]
            self.public_departure = record[15..18]
            self.platform = record[19..21].strip
            self.line = record[22..24].strip
            self.engineering_allowance = record[25..26].strip
            self.pathing_allowance = record[27..28].strip
            activity_list = record[29..40].strip
            self.performance_allowance = record[41..42].strip
          elsif self.location_type == "LI"
            self.arrival = record[10..14]
            self.departure = record[15..19]
            self.pass = record[20..24]
            self.public_arrival = record[25..28]
            self.public_departure = record[29..32]
            self.platform = record[33..35].strip
            self.line = record[36..38].strip
            self.path = record[39..41].strip
            activity_list = record[42..53].strip
            self.engineering_allowance = record[54..55].strip
            self.pathing_allowance = record[56..57].strip
            self.performance_allowance = record[58..59].strip
          elsif self.location_type == "LT"
            self.arrival = record[10..14]
            self.public_arrival = record[15..18]
            self.platform = record[19..21].strip
            self.path = record[22..24].strip
            activity_list = record[25..36].strip
          else
            raise "Unknown location type '#{self.location_type}'"
          end

          activities = CIF.parse_activities(activity_list)
          activities.keys.each do |a|
            self.send("#{a}=", activities[a])
          end

          self.tiploc_instance = nil if self.tiploc_instance == " "
          self.arrival = nil if self.arrival.blank?
          self.departure = nil if self.departure.blank?
          self.pass = nil if self.pass == "0000 " || self.pass.blank?
          self.public_arrival = nil if self.public_arrival == "0000"
          self.public_departure = nil if self.public_departure == "0000"
          self.line = nil if self.line == ""
          self.path = nil if self.path == ""
          self.platform = nil if self.platform == ""
          self.pathing_allowance = nil if self.pathing_allowance == ""
          self.engineering_allowance = nil if self.engineering_allowance == ""
          self.performance_allowance = nil if self.performance_allowance == ""

          self.arrival_secs = TSDBExplorer::time_to_seconds(self.arrival) unless self.arrival.nil?
          self.departure_secs = TSDBExplorer::time_to_seconds(self.departure) unless self.departure.nil?
          self.pass_secs = TSDBExplorer::time_to_seconds(self.pass) unless self.pass.nil?
          self.public_arrival_secs = TSDBExplorer::time_to_seconds(self.public_arrival) unless self.public_arrival.nil?
          self.public_departure_secs = TSDBExplorer::time_to_seconds(self.public_departure) unless self.public_departure.nil?

        end

      end

    end

    class BasicScheduleExtendedRecord

      FIELDS = [ :traction_class, :uic_code, :atoc_code, :ats_code, :rsid, :data_source ]

      attr_reader :traction_class, :uic_code, :atoc_code, :ats_code, :rsid, :data_source
      attr_accessor :traction_class, :uic_code, :atoc_code, :ats_code, :rsid, :data_source

      def initialize(record=nil)

        if record

          self.traction_class = record[2..5].strip
          self.uic_code = record[6..10]
          self.atoc_code = record[11..12]
          self.ats_code = record[13..13]
          self.rsid = record[14..22].strip
          self.data_source = record[23..23].strip

          self.traction_class = self.traction_class.strip.empty? ? nil : self.traction_class.strip
          self.uic_code = self.uic_code.strip.empty? ? nil : self.uic_code.strip
          self.rsid = self.rsid.strip.empty? ? nil : self.rsid.strip
          self.data_source = self.data_source.strip.empty? ? nil : self.data_source.strip

        end

      end

    end

    class BasicScheduleRecord

      FIELDS = [ :uuid, :transaction_type, :train_uid, :train_identity_unique, :runs_from, :runs_to, :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa, :runs_su, :bh_running, :status, :category, :train_identity, :headcode, :course_indicator, :service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :oper_q, :oper_y, :train_class, :sleepers, :reservations, :connection_indicator, :catering_code, :service_branding, :stp_indicator, :uic_code, :atoc_code, :ats_code, :rsid, :data_source ]

      attr_reader :uuid, :transaction_type, :train_uid, :train_identity_unique, :runs_from, :runs_to, :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa, :runs_su, :bh_running, :status, :category, :train_identity, :headcode, :course_indicator, :service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :oper_q, :oper_y, :train_class, :sleepers, :reservations, :connection_indicator, :catering_code, :service_branding, :stp_indicator, :uic_code, :atoc_code, :ats_code, :rsid, :data_source
      attr_accessor :uuid, :transaction_type, :train_uid, :train_identity_unique, :runs_from, :runs_to, :runs_mo, :runs_tu, :runs_we, :runs_th, :runs_fr, :runs_sa, :runs_su, :bh_running, :status, :category, :train_identity, :headcode, :course_indicator, :service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :oper_q, :oper_y, :train_class, :sleepers, :reservations, :connection_indicator, :catering_code, :service_branding, :stp_indicator, :uic_code, :atoc_code, :ats_code, :rsid, :data_source

      def initialize(record=nil)

        if record

          self.transaction_type = record[2..2]
          self.train_uid = record[3..8]
          self.runs_from = TSDBExplorer::yymmdd_to_date(record[9..14])
          self.runs_to = TSDBExplorer::yymmdd_to_date(record[15..20])
          self.runs_mo = record[21..21]
          self.runs_tu = record[22..22]
          self.runs_we = record[23..23]
          self.runs_th = record[24..24]
          self.runs_fr = record[25..25]
          self.runs_sa = record[26..26]
          self.runs_su = record[27..27]
          self.bh_running = record[28..28].strip
          self.status = record[29..29]
          self.category = record[30..31].strip
          self.train_identity = record[32..35]
          self.headcode = record[36..39].strip
          self.service_code = record[41..48]
          self.portion_id = record[49..49].strip
          self.power_type = record[50..52].strip
          self.timing_load = record[53..56].strip
          self.speed = record[57..59]
          self.operating_characteristics = record[60..65].strip
          self.train_class = record[66..66]
          self.sleepers = record[67..67].strip
          self.reservations = record[68..68].strip
          self.catering_code = record[70..73].strip
          self.service_branding = record[74..77].strip
          self.stp_indicator = record[79..79]

          self.bh_running = nil if self.bh_running == ""
          self.headcode = nil if self.headcode == ""
          self.portion_id = nil if self.portion_id == ""
          self.power_type = nil if self.power_type == ""
          self.timing_load = nil if self.timing_load == ""
          self.operating_characteristics = nil if self.operating_characteristics == ""
          self.oper_q = true if self.operating_characteristics =~ /Q/
          self.oper_y = true if self.operating_characteristics =~ /Y/
          self.sleepers = nil if self.sleepers == ""
          self.reservations = nil if self.reservations == ""
          self.catering_code = nil if self.catering_code == ""
          self.service_branding = nil if self.service_branding == ""

          self.data_source = "CIF"

        end

      end

      def merge_bx_record(bx_record)

        raise "A BasicScheduleExtended object must be passed" unless bx_record.is_a? TSDBExplorer::CIF::BasicScheduleExtendedRecord

        self.uic_code = bx_record.uic_code
        self.atoc_code = bx_record.atoc_code
        self.ats_code = bx_record.ats_code
        self.rsid = bx_record.rsid

      end

    end

    class AssociationRecord

      FIELDS = [ :transaction_type, :main_train_uid, :assoc_train_uid, :association_start_date, :association_end_date, :association_mo, :association_tu, :association_we, :association_th, :association_fr, :association_sa, :association_su, :category, :date_indicator, :location, :base_location_suffix, :assoc_location_suffix, :diagram_type, :assoc_type, :stp_indicator ]

      attr_reader :transaction_type, :main_train_uid, :assoc_train_uid, :association_start_date, :association_end_date, :association_mo, :association_tu, :association_we, :association_th, :association_fr, :association_sa, :association_su, :category, :date_indicator, :location, :base_location_suffix, :assoc_location_suffix, :diagram_type, :assoc_type, :stp_indicator
      attr_writer :transaction_type, :main_train_uid, :assoc_train_uid, :association_start_date, :association_end_date, :association_mo, :association_tu, :association_we, :association_th, :association_fr, :association_sa, :association_su, :category, :date_indicator, :location, :base_location_suffix, :assoc_location_suffix, :diagram_type, :assoc_type, :stp_indicator

      def initialize(record=nil)

        if record

          self.transaction_type = record[2..2]
          self.main_train_uid = record[3..8]
          self.assoc_train_uid = record[9..14]
          self.association_start_date = Date.parse("20" + record[15..20])
          self.association_end_date = Date.parse("20" + record[21..26])
          self.association_mo = record[27..27].to_i
          self.association_tu = record[28..28].to_i
          self.association_we = record[29..29].to_i
          self.association_th = record[30..30].to_i
          self.association_fr = record[31..31].to_i
          self.association_sa = record[32..32].to_i
          self.association_su = record[33..33].to_i
          self.category = record[34..35]
          self.date_indicator = record[36..36]
          self.location = record[37..43].strip
          self.base_location_suffix = record[44..44].strip
          self.assoc_location_suffix = record[45..45].strip
          self.diagram_type = record[46..46]
          self.stp_indicator = record[79..79]

          self.base_location_suffix = nil if self.base_location_suffix.blank?
          self.assoc_location_suffix = nil if self.assoc_location_suffix.blank?

        end

      end

    end

    class ChangeEnRouteRecord

      FIELDS = [ :tiploc_code, :tiploc_instance, :category, :train_identity, :headcode, :course_indicator,:service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :train_class, :sleepers, :reservations, :catering_code, :service_branding, :traction_class, :uic_code, :rsid ]

      attr_reader :tiploc_code, :tiploc_instance, :category, :train_identity, :headcode, :course_indicator,:service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :train_class, :sleepers, :reservations, :catering_code, :service_branding, :traction_class, :uic_code, :rsid
      attr_writer :tiploc_code, :tiploc_instance, :category, :train_identity, :headcode, :course_indicator,:service_code, :portion_id, :power_type, :timing_load, :speed, :operating_characteristics, :train_class, :sleepers, :reservations, :catering_code, :service_branding, :traction_class, :uic_code, :rsid

      def initialize(record=nil)

        if record

          self.tiploc_code = record[2..8].strip
          self.tiploc_instance = record[9..9].strip
          self.category = record[10..11]
          self.train_identity = record[12..15]
          self.headcode = record[16..19]
          self.course_indicator = record[20..20]
          self.service_code = record[21..28]
          self.portion_id = record[29..29].strip
          self.power_type = record[30..32].strip
          self.timing_load = record[33..36].strip
          self.speed = record[37..39]
          self.operating_characteristics = record[40..43].strip
          self.train_class = record[46..46]
          self.sleepers = record[47..47].strip
          self.reservations = record[48..48]
          self.catering_code = record[49..52].strip
          self.service_branding = record[53..56].strip
          self.traction_class = record[57..60].strip
          self.uic_code = record[61..65].strip
          self.rsid = record[66..74].strip

          self.tiploc_instance = nil if self.tiploc_instance == ""
          self.portion_id = nil if self.portion_id == ""
          self.power_type = nil if self.power_type == ""
          self.timing_load = nil if self.timing_load == ""
          self.operating_characteristics = nil if self.operating_characteristics == ""
          self.sleepers = nil if self.sleepers == ""
          self.catering_code = nil if self.catering_code == ""
          self.service_branding = nil if self.service_branding == ""
          self.traction_class = nil if self.traction_class == ""
          self.uic_code = nil if self.uic_code == ""
          self.rsid = nil if self.rsid == ""

        end

      end

    end

  end

end
