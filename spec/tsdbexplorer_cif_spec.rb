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

require 'spec_helper'

describe "lib/tsdbexplorer/cif.rb" do

  # Location activity processing

  it "should correctly process a set of activities in to an array" do

    responses = [
                 [ 'TB', { :activity_tb => true } ],
                 [ 'TF', { :activity_tf => true } ],
                 [ 'D',  { :activity_d => true } ],
                 [ 'U',  { :activity_u => true } ],
                 [ 'N',  { :activity_n => true } ],
                 [ 'R',  { :activity_r => true } ],
                 [ 'S',  { :activity_s => true } ],
                 [ 'T',  { :activity_t => true } ],
                 [ 'OP', { :activity_op => true } ],
                 [ 'RM', { :activity_rm => true } ],
                 [ 'OPRM', { :activity_op => true, :activity_rm => true } ]
                ]

    responses.each do |r|
      activities = TSDBExplorer::CIF::parse_activities(r[0])
      r[1].keys.each do |fields_true|
        activities[fields_true].should be_true
      end
    end

  end


  # Record parsing

  it "should return nil when passed a nil record" do
    result = TSDBExplorer::CIF::parse_record(nil)
    result.should be_nil
  end

  it "should return nil when passed a blank record" do
    result = TSDBExplorer::CIF::parse_record("")
    result.should be_nil
  end

  it "should correctly parse a CIF 'AA' record" do
    expected_data = {:transaction_type=>'N', :main_train_uid=>'G31230', :assoc_train_uid=>'G31665', :association_start_date=>Date.parse('2011-05-22'), :association_end_date=>Date.parse('2011-12-04'), :association_mo=>0, :association_tu=>0, :association_we=>0, :association_th=>0, :association_fr=>0, :association_sa=>0, :association_su=>1, :category=>'NP', :date_indicator => 'S', :location=>'LEEDS', :base_location_suffix=>nil, :assoc_location_suffix=>nil, :diagram_type=>'T', :stp_indicator=>'P'}
    parsed_record = TSDBExplorer::CIF::parse_record('AANG31230G316651105221112040000001NPSLEEDS    TO                               P')
    parsed_record.should be_a TSDBExplorer::CIF::AssociationRecord
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end

  it "should correctly parse a CIF 'BS' record" do
    expected_data = {:timing_load=>"321", :status=>"P", :train_uid=>"C43391", :transaction_type=>"N", :connection_indicator=>nil, :category=>"OO", :bh_running=>nil, :stp_indicator=>"P", :speed=>"100", :catering_code=>nil, :headcode=>nil, :operating_characteristics=>nil, :service_branding=>nil, :service_code=>"22209000", :train_class=>"B", :runs_from=>"2010-12-12", :portion_id=>nil, :train_identity=>"2N53", :sleepers=>nil, :runs_to=>"2011-05-15", :power_type=>"EMU", :reservations=>"S", :runs_mo=>"0", :runs_tu=>"0", :runs_we=>"0", :runs_th=>"0", :runs_fr=>"0", :runs_sa=>"0", :runs_su=>"1"}
    parsed_record = TSDBExplorer::CIF::parse_record('BSNC433911012121105150000001 POO2N53    122209000 EMU321 100      B S          P')
    parsed_record.should be_a TSDBExplorer::CIF::BasicScheduleRecord
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end

  it "should correctly parse a CIF 'BX' record" do
    expected_data = {:uic_code=>"48488", :atoc_code=>"ZZ", :ats_code=>"Y", :rsid=>"ZZ000000", :data_source=>nil, :traction_class=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('BX    48488ZZYZZ000000                                                          ')
    parsed_record.should be_a TSDBExplorer::CIF::BasicScheduleExtendedRecord
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end

  it "should correctly parse a CIF 'LO' record" do
    expected_data = {:performance_allowance=>nil, :platform=>"3", :departure=>"0910 ", :public_departure=>nil, :record_identity=>"LO", :engineering_allowance=>nil, :line=>nil, :tiploc_code=>"PENZNCE", :pathing_allowance=>nil, :activity_tb=>true, :activity_tf=>false, :activity_d=>false, :activity_u=>false, :activity_n=>false, :activity_r=>false, :activity_s=>false, :activity_t=>false, :activity_rm=>true, :activity_a=>true, :activity_minusd=>true, :tiploc_instance=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('LOPENZNCE 0910 00003         TBRMA -D                                           ')
    parsed_record.should be_a TSDBExplorer::CIF::LocationRecord
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end

  it "should correctly parse a CIF 'LI' record" do
    expected_data = {:performance_allowance=>nil, :platform=>"15", :pass=>nil, :path=>nil, :departure=>"1532H", :arrival=>"1429H", :public_departure=>nil, :public_arrival=>nil, :record_identity=>"LI", :engineering_allowance=>nil, :line=>"E", :tiploc_code=>"EUSTON", :pathing_allowance=>nil, :activity_tb=>false, :activity_tf=>false, :activity_d=>false, :activity_u=>false, :activity_n=>false, :activity_r=>false, :activity_s=>false, :activity_t=>false, :activity_rm=>true, :activity_op=>true, :tiploc_instance=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('LIEUSTON  1429H1532H     0000000015 E     RMOP                                  ')
    parsed_record.should be_a TSDBExplorer::CIF::LocationRecord
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end

  it "should correctly parse a CIF 'LT' record" do
    expected_data = {:platform=>nil, :path=>nil, :arrival=>"0417 ", :public_arrival=>nil, :record_identity=>"LT", :tiploc_code=>"DITTFLR", :activity_tb=>false, :activity_tf=>true, :activity_d=>false, :activity_u=>false, :activity_n=>false, :activity_r=>false, :activity_s=>false, :activity_t=>false, :activity_pr=>true, :tiploc_instance=>nil}
    parsed_record = TSDBExplorer::CIF::parse_record('LTDITTFLR 0417 0000      TFPR                                                   ')
    parsed_record.should be_a TSDBExplorer::CIF::LocationRecord
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end

  it "should correctly parse a CIF 'CR' record" do
    expected_data = {:timing_load=>"350", :speed=>"100", :course_indicator=>"1", :catering_code=>nil, :headcode=>"2130", :rsid=>"LM000000", :operating_characteristics=>nil, :tiploc_code=>"NMPTN", :service_branding=>nil, :service_code=>"22209000", :train_identity=>"1U30", :train_class=>"B", :traction_class=>nil, :portion_id=>nil, :sleepers=>nil, :tiploc_instance=>nil, :uic_code=>nil, :power_type=>"EMU", :reservations=>"S", :category=>"XX"}
    parsed_record = TSDBExplorer::CIF::parse_record('CRNMPTN   XX1U302130122209000 EMU350 100      B S                  LM000000     ')
    expected_data.collect.each { |k,v| parsed_record.send(k).should eql(v) }
  end


  # File parsing - error and edge conditions

  it "should handle gracefully a nonexistent CIF file" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/DOES_NOT_EXIST.cif')
    result.status.should eql(:error)
    result.message.should =~ /CIF file test\/fixtures\/cif\/DOES_NOT_EXIST.cif does not exist/
  end

  it "should reject an empty CIF file" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/blank_file.cif')
    result.status.should eql(:error)
    result.message.should =~ /No CIF HD record found at the beginning of test\/fixtures\/cif\/blank_file.cif/
  end

  it "should reject a CIF file with an unknown record" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/unknown_record_type.cif')
    result.status.should eql(:error)
    result.message.should =~ /Unsupported record type '9Z' found/
  end

  it "should permit a CIF file with only an HD and ZZ record" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/header_and_trailer.cif')
    result.status.should eql(:ok)
    result.message.should =~ /TIPLOCs: 0 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Schedules: 0 inserted, 0 amended, 0 deleted/
  end


  # TIPLOC Record processing

  it "should process TI records from a CIF file" do

    Tiploc.all.count.should eql(0)
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ti.cif')
    result.status.should eql(:ok)
    result.message.should =~ /TIPLOCs: 1 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Schedules: 0 inserted, 0 amended, 0 deleted/  
    Tiploc.all.count.should eql(1)
    
    expected_record = {:crs_code=>"EUS", :tps_description=>"LONDON EUSTON", :stanox=>"72410", :nalco=>"144400", :tiploc_code=>"EUSTON", :description=>"LONDON EUSTON"}
    actual_record = Tiploc.find_by_stanox('72410').attributes

    expected_record.each do |k,v|
      actual_record[k.to_s].should eql(v)
    end

  end

  it "should not allow TA records in a CIF full extract" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_full.cif')
    result.status.should eql(:error)
    result.message.should =~ /TIPLOC Amend \(TA\) record not allowed in a CIF full extract/
  end

  it "should process TA records from a CIF file" do

    result_1 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_part1.cif')
    result_1.status.should eql(:ok)
    result_1.message.should =~ /TIPLOCs: 1 inserted, 0 amended, 0 deleted/
    result_1.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_1.message.should =~ /Schedules: 0 inserted, 0 amended, 0 deleted/  
    Tiploc.count.should eql(1)
    
    result_2 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_ta_part2.cif')
    result_2.status.should eql(:ok)
    result_2.message.should =~ /TIPLOCs: 0 inserted, 1 amended, 0 deleted/
    result_2.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_2.message.should =~ /Schedules: 0 inserted, 0 amended, 0 deleted/  
    Tiploc.count.should eql(1)

    expected_record = {:description=>"SMITHAM", :stanox=>"87705", :crs_code=>"SMI", :tiploc_code=>"SMITHAM", :tps_description=>"SMITHAM", :nalco=>"638600"}
    actual_record = Tiploc.find_by_crs_code('SMI').attributes

    expected_record.each do |k,v|
      actual_record[k.to_s].should eql(v)
    end

  end

  it "should not allow TD records in a CIF full extract" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td_full.cif')
    result.status.should eql(:error)
    result.message.should =~ /TIPLOC Delete \(TD\) record not allowed in a CIF full extract/
  end

  it "should process TD records from a CIF file" do

    result_1 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td_part1.cif')
    result_1.status.should eql(:ok)
    result_1.message.should =~ /TIPLOCs: 2 inserted, 0 amended, 0 deleted/
    result_1.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_1.message.should =~ /Schedules: 0 inserted, 0 amended, 0 deleted/  
    Tiploc.count.should eql(2)

    result_2 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_td_part2.cif')
    result_2.status.should eql(:ok)
    result_2.message.should =~ /TIPLOCs: 0 inserted, 0 amended, 1 deleted/
    result_2.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_2.message.should =~ /Schedules: 0 inserted, 0 amended, 0 deleted/  
    Tiploc.count.should eql(1)
    Tiploc.find_by_tiploc_code('WATFDJ').should_not be_nil

  end


  # Basic Schedule (New) record processing

  it "should process BS 'new' records in a CIF full extract" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')

    result.status.should eql(:ok)
    result.message.should =~ /TIPLOCs: 18 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Schedules: 1 inserted, 0 amended, 0 deleted/

    BasicSchedule.count.should eql(1)
    BasicSchedule.first.atoc_code.should eql('LM')
    BasicSchedule.first.ats_code.should eql('Y')
    BasicSchedule.first.data_source.should eql('CIF')
    Location.count.should eql(18)
    Location.first.tiploc_code.should eql('EUSTON')
    Location.last.tiploc_code.should eql('NMPTN')
  end

  it "should process BS 'new' records in a CIF update extract" do
    result_1 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_updateextract_part1.cif')
    result_1.status.should eql(:ok)

    result_2 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_updateextract_part2.cif')
    result_2.status.should eql(:ok)
    result_2.status.should eql(:ok)
    result_2.message.should =~ /TIPLOCs: 18 inserted, 0 amended, 0 deleted/
    result_2.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_2.message.should =~ /Schedules: 1 inserted, 0 amended, 0 deleted/
                
    BasicSchedule.count.should eql(1)
    Location.count.should eql(18)
    Location.first.tiploc_code.should eql('EUSTON')
    Location.last.tiploc_code.should eql('NMPTN')
  end

  it "should not allow BS 'delete' records in a CIF full extract" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_fullextract.cif')
    result.status.should eql(:error)
    result.message.should =~ /Basic Schedule Delete \(BSD\) record not allowed in a CIF full extract/
  end

  it "should process BS 'delete' records in a CIF update extract" do
    result_1 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_part1.cif')

    result_1.status.should eql(:ok)
    result_1.message.should =~ /TIPLOCs: 5 inserted, 0 amended, 0 deleted/
    result_1.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_1.message.should =~ /Schedules: 1 inserted, 0 amended, 0 deleted/

    BasicSchedule.count.should eql(1)
    Location.count.should eql(5)

    result_2 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_delete_part2.cif')
    result_2.status.should eql(:ok)
    result_2.message.should =~ /TIPLOCs: 0 inserted, 0 amended, 0 deleted/
    result_2.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_2.message.should =~ /Schedules: 0 inserted, 0 amended, 1 deleted/

    BasicSchedule.count.should eql(0)
    Location.count.should eql(0)
  end

  it "should not allow BS 'revise' records in a CIF full extract" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_revise_fullextract.cif')
    result.status.should eql(:error)
    result.message.should =~ /Basic Schedule revise \(BSR\) record not allowed in a CIF full extract/
  end

  it "should process BS 'revise' records in a CIF update extract" do
    expected_data_part_1 = {:tiploc=>{:insert=>13, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>1, :delete=>0, :amend=>0}}
    result_1 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_revise_part1.cif')
    result_1.status.should eql(:ok)
    result_1.message.should =~ /TIPLOCs: 13 inserted, 0 amended, 0 deleted/
    result_1.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_1.message.should =~ /Schedules: 1 inserted, 0 amended, 0 deleted/

    BasicSchedule.count.should eql(1)
    Location.count.should eql(13)

    expected_data_part_2 = {:tiploc=>{:insert=>0, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>0, :delete=>0, :amend=>1}}
    result_2 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_revise_part2.cif')
    result_2.status.should eql(:ok)
    result_2.message.should =~ /TIPLOCs: 0 inserted, 0 amended, 0 deleted/
    result_2.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result_2.message.should =~ /Schedules: 0 inserted, 1 amended, 0 deleted/

    BasicSchedule.count.should eql(1)
    Location.count.should eql(13)
  end

  it "should not allow unknown BS record transaction types in a CIF extract" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_invalid.cif')
    result.status.should eql(:error)
    result.message.should =~ /Unknown BS transaction type Z found/
  end

  it "should strip white space from the power type and timing load columns" do
    BasicSchedule.count.should eql(0)
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/whitespace_strip.cif')
    schedule = BasicSchedule.first
    schedule.power_type.should eql('E')
    schedule.timing_load.should eql('410')
  end

  it "should identify schedules which run as required (Q)" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/runs_as_required.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('C05395', Date.parse('2011-12-11')).first
    schedule.oper_q.should be_true
    schedule.oper_y.should_not be_true
  end

  it "should identify schedules which run as required to terminals/yards (Y)" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/runs_as_required.cif')
    schedule = BasicSchedule.runs_on_by_uid_and_date('G67076', Date.parse('2012-01-09')).first
    schedule.oper_q.should_not be_true
    schedule.oper_y.should be_true
  end


  # Sequence processing

  it "should include an incrementing sequence number with schedule locations" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')

    schedule = BasicSchedule.first

    last_id = 0

    schedule.locations.each do |loc|
      loc.seq.should > last_id
      last_id = loc.seq
    end 

  end


  # Activity processing

  it "should set the activity_tb column on the location where the train begins" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.first
    london_euston = schedule.locations.where(:tiploc_code => 'EUSTON').first
    london_euston.activity_tb.should be_true
  end

  it "should set the activity_d column on locations where the train stops to set down passengers only" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    schedule = BasicSchedule.where(:train_uid => 'P64024').first
    watford_junction = schedule.locations.where(:tiploc_code => 'WATFDJ').first
    watford_junction.activity_d.should be_true
  end

  it "should set the activity_u column on locations where the train stops to pick up passengers only" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/pickup_and_setdown.cif')
    schedule = BasicSchedule.where(:train_uid => 'P64437').first
    watford_junction = schedule.locations.where(:tiploc_code => 'WATFDJ').first
    watford_junction.activity_u.should be_true
  end

  it "should set the activity_n column on locations where the stop is unadvertised" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/paisley_to_ayr.cif')
    schedule = BasicSchedule.where(:train_uid => 'G46077').first
    johnston = schedule.locations.where(:tiploc_code => 'JOHNSTN').first
    johnston.activity_n.should be_true
    prestwick = schedule.locations.where(:tiploc_code => 'PWCK').first
    prestwick.activity_n.should be_true
  end

  it "should set the activity_r column on locations where the train stops only when required" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/crewe_to_holyhead.cif')
    schedule = BasicSchedule.where(:train_uid => 'P83051').first
    watford_junction = schedule.locations.where(:tiploc_code => 'LFPW').first
    watford_junction.activity_r.should be_true
  end

  it "should set the activity_s column on locations where the train stops for railway personnel only" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/brighton_to_victoria.cif')
    schedule = BasicSchedule.where(:train_uid => 'W52132').first
    watford_junction = schedule.locations.where(:tiploc_code => 'SELHRST').first
    watford_junction.activity_s.should be_true
  end

  it "should set the activity_t column on locations where the train stops to pick up and set down passengers" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.first
    watford_junction = schedule.locations.where(:tiploc_code => 'WATFDJ').first
    watford_junction.activity_t.should be_true
  end

  it "should set the activity_tf column on the location where the train finishes" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    schedule = BasicSchedule.first
    northampton = schedule.locations.where(:tiploc_code => 'NMPTN').first
    northampton.activity_tf.should be_true
  end


  # Time procesing

  it "should process Basic Schedule arrival, public arrival, passing, departure and public departure times correctly" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    basic_schedule = BasicSchedule.first
    locations = basic_schedule.locations

    # Originating locations must have only a departure time
    locations.first.arrival.should be_nil
    locations.first.arrival_secs.should be_nil
    locations.first.public_arrival.should be_nil
    locations.first.public_arrival_secs.should be_nil
    locations.first.pass.should be_nil
    locations.first.pass_secs.should be_nil
    locations.first.departure.should eql('1834 ')
    locations.first.departure_secs.should eql(66840)
    locations.first.public_departure.should eql('1834')
    locations.first.public_departure_secs.should eql(66840)

    # Passing points must have only a passing time
    locations[2].arrival.should be_nil
    locations[2].arrival_secs.should be_nil
    locations[2].public_arrival.should be_nil
    locations[2].public_arrival_secs.should be_nil
    locations[2].pass.should eql('1837H')
    locations[2].pass_secs.should eql(67050)
    locations[2].departure.should be_nil
    locations[2].departure_secs.should be_nil
    locations[2].public_departure.should be_nil
    locations[2].public_departure_secs.should be_nil

    # Calling points must have only an arrival, public arrival, departure and public departure time only
    locations[6].arrival.should eql('1850 ')
    locations[6].arrival_secs.should eql(67800)
    locations[6].public_arrival.should eql('1850')
    locations[6].public_arrival_secs.should eql(67800)
    locations[6].pass.should be_nil
    locations[6].pass_secs.should be_nil
    locations[6].departure.should eql('1851 ')
    locations[6].departure_secs.should eql(67860)
    locations[6].public_departure.should eql('1851')
    locations[6].public_departure_secs.should eql(67860)

    # Terminating locations must have only an arrival and public arrival time
    locations.last.arrival.should eql('1946 ')
    locations.last.public_arrival.should eql('1946')
    locations.last.pass.should be_nil
    locations.last.departure.should be_nil
    locations.last.public_departure.should be_nil
  end


  it "should set the next_day flag on locations where the schedule originated the previous day (example 1)" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/bri_sunday_evening.cif')

    schedule = BasicSchedule.first

    next_day_false = ['CRDFCEN', 'MSHFILD', 'EBBWJ', 'NWPTRTG', 'MAINDWJ', 'LWERWJN']
    next_day_true = ['SEVTNLJ', 'SEVTNLW', 'SEVTNLE', 'PILNING', 'PATCHWY', 'FILTNEW', 'STPLNAR', 'STPLTNR', 'LAWRNCH', 'DRDAYSJ', 'BRSTLEJ', 'BRSTLTM']

    next_day_false.each do |loc|
      schedule.locations.where(:tiploc_code => loc).first.next_day_arrival.should be_false
      schedule.locations.where(:tiploc_code => loc).first.next_day_departure.should be_false
    end

    next_day_true.each do |loc|
      schedule.locations.where(:tiploc_code => loc).first.next_day_arrival.should be_true
      schedule.locations.where(:tiploc_code => loc).first.next_day_departure.should be_true
    end

  end

  it "should set the next_day flag on locations where the schedule originated the previous day (example 2)" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/train_over_midnight.cif')

    schedule = BasicSchedule.where(:train_uid => 'L73705').first

    next_day_false = ['EUSTON']
    next_day_true = ['CMDNSTH', 'CMDNJN', 'SHMPSTD', 'KLBRNHR', 'QPRK', 'QPRKJ', 'KENSLG', 'WLSDNJL', 'HARLSDN', 'STNBGPK', 'WMBYDC', 'NWEMBLY', 'SKENTON', 'KTON', 'HROWDC', 'HEDSTNL', 'HTCHEND', 'CRPNDPK', 'BUSHYDC', 'WATFDHS', 'WATFJDC']

    next_day_false.each do |loc|
      schedule.locations.where(:tiploc_code => loc).first.next_day_arrival.should be_false
      schedule.locations.where(:tiploc_code => loc).first.next_day_departure.should be_false
    end

    next_day_true.each do |loc|
      schedule.locations.where(:tiploc_code => loc).first.next_day_arrival.should be_true
      schedule.locations.where(:tiploc_code => loc).first.next_day_departure.should be_true
    end

  end


  # Bus and Ship processing

  it "should handle schedules for buses" do
    expected_data = {:tiploc=>{:insert=>3, :delete=>0, :amend=>0}, :association=>{:insert=>0, :delete=>0, :amend=>0}, :schedule=>{:insert=>1, :delete=>0, :amend=>0}}
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_bus.cif')
    result.status.should eql(:ok)
    result.message.should =~ /TIPLOCs: 3 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Schedules: 1 inserted, 0 amended, 0 deleted/

    basic_schedule = BasicSchedule.first
    basic_schedule.train_identity.should eql('0B00')
    basic_schedule.status.should eql('B')
    locations = basic_schedule.locations
    basic_schedule.locations.count.should eql(3)
    locations.first.line.should eql('BUS')
  end

  it "should handle schedules for ships" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_ship.cif')
    result.status.should eql(:ok)
    result.message.should =~ /TIPLOCs: 2 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Associations: 0 inserted, 0 amended, 0 deleted/
    result.message.should =~ /Schedules: 1 inserted, 0 amended, 0 deleted/

    basic_schedule = BasicSchedule.first
    basic_schedule.train_identity.should eql('0S00')
    basic_schedule.status.should eql('S')
    locations = basic_schedule.locations
    basic_schedule.locations.count.should eql(2)
  end


  # Timetable administration

  it "should record the details of a CIF file imported" do

    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')

    expected_data = { :file_ref => 'DFTESTA', :extract_timestamp => Time.parse('1970-01-01 00:00:00'), :start_date => Date.parse('1970-01-01'), :end_date => Date.parse('1970-01-01'), :update_indicator => 'F', :file_mainframe_identity => 'TPS.UDFTEST.PD700101', :mainframe_username => 'DFTEST' }
    data = CifFile.first

    expected_data.each do |k,v|
      data[k].should eql(v)
    end

  end

  it "should allow the next-in-sequence CIF file to be imported" do
    result_a = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/ordering/DFTESTA.CIF')
    result_a.status.should eql(:ok)
    result_b = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/ordering/DFTESTB.CIF')
    result_b.status.should eql(:ok)
  end

  it "should not allow an out-of-sequence CIF update file to be imported" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/ordering/DFTESTB.CIF')
    result.status.should eql(:error)
    result.message.should eql('CIF update DFTESTB must be applied after file DFTESTA')
  end

  it "should allow an out-of-sequence CIF full extract file to be imported" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/ordering/DFTESTC.CIF')
    result.status.should eql(:ok)
  end


  # Bugs

  it "should process a CIF update with a new cancellation followed by the deletion of an existing cancellation" do
    result_1 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/bug_issue_95_part1.cif')
    result_1.status.should eql(:ok)
    result_1.message.should =~ /Schedules: 1 inserted, 0 amended, 0 deleted/
    result_2 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/bug_issue_95_part2.cif')
    result_2.status.should eql(:ok)
    result_2.message.should =~ /Schedules: 1 inserted, 0 amended, 1 deleted/
  end

  it "should process a CIF update with a revision where the schedule end date is altered" do

    result_1 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/bug_revise_date_part1.cif')
    result_1.status.should eql(:ok)
    result_1.message.should =~ /Schedules: 2 inserted, 0 amended, 0 deleted/
    num_records_1 = BasicSchedule.all.count
    num_records_1.should eql(2)

    p_schedule_1 = BasicSchedule.where(:train_uid => 'G09079').where(:runs_from => '2012-05-20').where(:stp_indicator => 'P')
    p_schedule_1.count.should eql(1)

    o_schedule_1 = BasicSchedule.where(:train_uid => 'G09079').where(:runs_from => '2012-05-20').where(:stp_indicator => 'O')
    o_schedule_1.count.should eql(1)

    result_2 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/bug_revise_date_part2.cif')
    result_2.status.should eql(:ok)
    result_2.message.should =~ /Schedules: 0 inserted, 1 amended, 0 deleted/
    num_records_2 = BasicSchedule.all.count
    num_records_2.should eql(2)

    p_schedule_2 = BasicSchedule.where(:train_uid => 'G09079').where(:runs_from => '2012-05-20').where(:stp_indicator => 'P')
    p_schedule_2.count.should eql(1)

    o_schedule_2 = BasicSchedule.where(:train_uid => 'G09079').where(:runs_from => '2012-05-20').where(:stp_indicator => 'O')
    o_schedule_2.count.should eql(1)

    result_3 = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/bug_revise_date_part3.cif')
    result_3.status.should eql(:ok)
    result_3.message.should =~ /Schedules: 1 inserted, 1 amended, 0 deleted/

    BasicSchedule.count.should eql(3)

    p_schedule_3 = BasicSchedule.where(:train_uid => 'G09079').where(:runs_from => '2012-05-20').where(:stp_indicator => 'P')
    p_schedule_3.count.should eql(1)

    o1_schedule_3 = BasicSchedule.where(:train_uid => 'G09079').where(:runs_from => '2012-05-20').where(:stp_indicator => 'O')
    o1_schedule_3.count.should eql(1)
    o1_schedule_3.first.runs_to.should eql(Date.parse('2012-05-20'))

    o2_schedule_3 = BasicSchedule.where(:train_uid => 'G09079').where(:runs_from => '2012-05-27').where(:stp_indicator => 'O')
    o2_schedule_3.count.should eql(1)
    o2_schedule_3.first.runs_to.should eql(Date.parse('2012-05-27'))

  end

end
