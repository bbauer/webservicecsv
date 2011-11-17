require 'savon'
require 'csv'

class SitelinkCsv

  WSDL_URL = "http://www.smdservers.net/CCWs_3.5/CallCenterWs.asmx?WSDL"
  VERSION = "2.1"

  def initialize(options={})
    if options[:corp_code] && options[:user] && options[:password]
      @corp_code = options[:corp_code]
      @user      = options[:user]
      @password  = options[:password]
      @client    = Savon::Client.new do
        wsdl.document = WSDL_URL
      end
    else
      puts "You need all the creds biotch!"
    end
  end

  def get_units(location_code="")
    unless location_code.empty?
      units= []
      response = @client.request :units_information_v2, body: { 'sCorpCode' => @corp_code, 'sLocationCode' => location_code, 'sCorpUserName' => @user, 'sCorpPassword' => @password, 'sLastTimePolled' => 0 }
      tables = response.xpath('//Table')
      tables.each do |t|
        unit = {}
        unit[:ret_code] = t.at_xpath('Ret_Code').text
        unit[:unit_type_id] = t.at_xpath('UnitTypeID').text
        unit[:s_type_name] = t.at_xpath('sTypeName').text
        unit[:i_def_lease_num] = t.at_xpath('iDefLeaseNum').text.to_i || 0
        unit[:unit_id] = t.at_xpath('UnitID').text
        unit[:s_unit_name] = t.at_xpath('sUnitName').text
        unit[:dc_width] = t.at_xpath('dcWidth').text.to_f || 0.00
        unit[:dc_length] = t.at_xpath('dcLength').text.to_f || 0.00
        unit[:b_climate] = t.at_xpath('bClimate').text == true
        unit[:dc_std_rate] = t.at_xpath('dcStdRate').text.to_f || 0.00
        unit[:b_rented] = t.at_xpath('bRented').text == true
        unit[:b_inside] = t.at_xpath('bInside').text == true
        unit[:b_power] = t.at_xpath('bPower').text == true
        unit[:b_alarm] = t.at_xpath('bAlarm').text == true
        unit[:i_floor] = t.at_xpath('iFloor').text.to_i || 0
        unit[:b_waiting_list_reserved] = t.at_xpath('bWaitingListReserved').text == true
        unit[:b_corporate] = t.at_xpath('bCorporate').text == true
        unit[:b_rentable] = t.at_xpath('bRentable').text == true
        unit[:dc_board_rate] = t.at_xpath('dcBoardRate').text.to_f || 0.00
        unit[:dc_push_rate] = t.at_xpath('dcPushRate').text.to_f || 0.00
        unit[:dc_tax1_rate] = t.at_xpath('dcTax1Rate').text.to_f || 0.00
        unit[:dc_tax2_rate] = t.at_xpath('dcTax2Rate').text.to_f || 0.00
        unit[:dc_std_weekly_rate] = t.at_xpath('dcStdWeeklyRate').text.to_f || 0.00
        units << unit
      end
    end
    units
  end

  def output_csv(location_code="", file="")
    unless location_code.empty? || file.empty?
      units = get_units(location_code)
      CSV.open(file, "w") do |csv|
        csv << ["ret_code","unit_type_id","s_type_name","i_def_lease_num","unit_id","s_unit_name","dc_width","dc_length","b_climate","dc_std_rate","b_rented","b_inside","b_power","b_alarm","i_floor","b_waiting_list_reserved","b_corporate","b_rentable","dc_board_rate","dc_push_rate","dc_tax1_rate","dc_tax2_rate","dc_std_weekly_rate"]
        units.each do |unit|
          csv << [
            unit[:ret_code], 
            unit[:unit_type_id], 
            unit[:s_type_name], 
            unit[:i_def_lease_num], 
            unit[:unit_id], 
            unit[:s_unit_name], 
            unit[:dc_width], 
            unit[:dc_length], 
            unit[:b_climate], 
            unit[:dc_std_rate], 
            unit[:b_rented], 
            unit[:b_inside], 
            unit[:b_power], 
            unit[:b_alarm], 
            unit[:i_floor], 
            unit[:b_waiting_list_reserved], 
            unit[:b_corporate], 
            unit[:b_rentable], 
            unit[:dc_board_rate], 
            unit[:dc_push_rate], 
            unit[:dc_tax1_rate], 
            unit[:dc_tax2_rate], 
            unit[:dc_std_weekly_rate]
          ]
        end
      end
    end
  end

end