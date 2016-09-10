require 'yomu'
require 'date'
require 'csv'
require 'similar_text'

class String
  def from_money_to_f 
    self ? self.strip.gsub(/,$/, '').to_f : 0
  end  
end

class NilClass
  def from_money_to_f 
    ""
  end 
end

class Segment

  attr_reader :confirmation_number
  attr_reader :guest_name
  attr_reader :hotel_name
  attr_reader :chain
  attr_reader :checkin_date
  attr_reader :checkout_date

  def initialize(type, row, header)

    @type = type

    if type == "mos_commissions"

      @company = row[header['company']]
      @booking_id = row[header['trip_id']]
      @consultant = row[header['consultants']]                
      @guest_name = row[header['travellers']]
      @costing_id = row[header['costing_id']]
      @link = row[header['link']]
      @hotel_name = row[header['supplier_name']] 
      @checkout_date = row[header['departure_date']]
      @checkout_date = Date.parse(@checkout_date)
      @room_nights = row[header['duration']].to_i
      @checkin_date = checkout_date - @room_nights
      @rate = row[header['rate']].from_money_to_f
      @revenue = row[header['total_aud']].from_money_to_f
      @currency = row[header['currency_code']]
      @expected_commission = row[header['expected_commission_aud']].from_money_to_f
      @commission_received =  row[header['commission_received']].from_money_to_f
      @confirmation_number = row[header['confirmation_number']]

    end

    if type == "mos_segments"
      
      @consultant = row[header['consultants']]
      @company = row[header['company']]
      @guest_name = row[header['traveller_name']]
      @dom_or_int = row[header['travel_type']]
      @revenue = (row[header['amount_total']] || "0").from_money_to_f
      @currency = row[header['currency_code']]
      @confirmation_number = row[header['confirmation_number']]
      @hotel_name = row[header['supplier_name']]
      @checkin_date = row[header['arrival_date']]
      @checkin_date = Date.parse(@checkin_date)
      @checkout_date = row[header['departure_date']]
      @checkout_date = Date.parse(@checkout_date)
      @room_nights = (checkout_date - checkin_date).to_i
      @hotel_id = row[header['supplier_code']]
    end

    #@gds_code = row[header['gds_id']]
    if type == "sabre_segments"

      @chain = (row[header['Chain']])
      @company = (row[header['Company']] || "").strip
      @booking_id = (row[header['Booking Id']] || "").strip
      @consultant = (row[header['Consultant']] || "").strip                
      @guest_name = (row[header['Passenger Name']] || "").strip
      @costing_id = row[header['Costing Unique']]
      @link = get_sam_link
      @hotel_name = row[header['Hotel']] 
      if @checkout_date = row[header['Return Day']]
        if @checkout_date.strip != ""
          @checkout_date = Date.strptime(@checkout_date, '%d/%m/%Y')
        end
      end
      #if @checkin_date = row[header['Departure Day']] || row[header['Travel Day']]
      if @checkin_date = row[header['Travel Day']]
        @checkin_date = Date.strptime(@checkin_date, '%d/%m/%Y')
      end 
      @room_nights = row[header['Room Nights']]
      @rate = row[header['Rate']].from_money_to_f
      @revenue = row[header['Original Amount']].from_money_to_f
      @currency = row[header['Currency Code']].strip
      @expected_commission = row[header['Expected Commission AUD']].from_money_to_f
      @commission_received =  row[header['Commission Paid']].from_money_to_f
      @confirmation_number = row[header['Segment Reference']]
      @hotel_id = (row[header['Hotel Id']] || "").strip

    end

 

  end

  def get_array
    [
    @type,
    @company, 
    @booking_id,
    @consultant,
    @guest_name, 
    @costing_id, 
    @link,
    @chain, 
    @hotel_name, 
    @booking_id,
    @checkin_date, 
    @checkout_date, 
    @rate, 
    @revenue, 
    @currency, 
    @expected_commission, 
    @commission_received,
    @confirmation_number,
    @hotel_id, 
    @gds_code
    ] 
  end

  def match_statments(statements)
    #puts @confirmation_number
  end

  def get_sam_link
     "https://sam-au2.sabrepacific.net.au/Nova/Web/Profiles/Profiles.aspx?" +
     "ProfileType=2&Code=" + @booking_id + "&ClassName=Costing&MenuId=Costing"
  end

end


class Statement

  attr_reader     :filename
  attr_reader     :chain 
  attr_reader     :hotel_name  
  attr_reader     :address
  attr_reader     :city
  attr_reader     :guest_name
  attr_reader     :agency 
  attr_reader     :confirmation_number
  attr_reader     :src 
  attr_reader     :checkin_date 
  attr_reader     :checkout_date 
  attr_reader     :room_nights
  attr_reader     :status 
  attr_reader     :revenue 
  attr_reader     :gross_commission 
  attr_reader     :adjust_amount 
  attr_reader     :tax_amount 
  attr_reader     :tax_type
  attr_reader     :currency
  attr_reader     :comm_paid_aud
  
  def initialize (type, filename, line, extras)
    #puts extras

    @filename = filename

    if type == 'onyx'
      #puts line
      begin
        @chain = extras[:chain]
        @city = extras[:city]
        @statement_date = extras[:period_ending]
        @hotel_name = extras[:hotel_name]
        @city = @city || "unknown"
        @city = @city.gsub('(CONTINUED)','')
        @city.strip!
        @guest_name = line[4..32] || "unknown"
        @guest_name = @guest_name.strip
        @agency = line[34..43].strip.upcase
        @confirmation_number = line[44..54].strip.upcase
        @src = line[56..59].strip.upcase
        @checkin_date = Date.strptime(line[61..70], '%m/%d/%y')
        @room_nights = line[71..77].strip.to_i
        @checkout_date = checkin_date + room_nights
        @status = line[79..86].strip
        @revenue = line[96..103].gsub(/[^\d\.]/,'')
        @revenue = revenue.to_f
        @gross_commission = line[106..115].strip.to_f
        @adjust_amount = line [118..124].strip.to_f
        @tax_amount = line[126..134].strip.to_f
        @tax_type = line[135..140].strip
        @currency = line[154..158].strip
        @commission_paid_aud = line[161..-1].gsub(/[^\d\.]/,'').strip.to_f
        @collector_commission = @commission_paid_aud * 0.12
        @commission_less_collector = @commission_paid_aud * 0.88
      rescue
        puts "error with a line in onyx file" 
        puts line
      end

      #puts @name, @agency, @reference, @src
    end

    if type == "tacs"
      #puts line
      @guest_name = line[0..37]
      #puts name
      @guest_name.strip!
      @confirmation_number = (line[37..50] || "").strip
      @description = (line[51..66] || "").strip
      @checkin_date = Date.strptime(line[67..74], '%Y%m%d')
      @checkout_date = Date.strptime(line[76..86], '%Y%m%d')
      @room_nights = line[85..90].to_i
      @units = line[89..93].to_i
      @revenue = line[93..105].to_f
      @gross_commission = line[104..118].to_f
      @tax_type = (line[117..137] || "").strip
      @tax_amount = line[138..154].to_f
      @commission_amount = line[150..159].to_f
      @commission_paid_aud = line[160..173].to_f
      @currency = extras[:currency]
      @country = extras[:country]
      @hotel_id = extras[:hotel_id]
      @hotel_name = extras[:hotel_name]
      @city = extras[:city]
      @statement_no = extras[:statement_no]
      @statement_date = extras[:payment_date]
      @collector_commission = @commission_paid_aud * extras[:commission_percentage]
      @commission_less_collector = @commission_paid_aud * (1 - extras[:commission_percentage])
    end

    

    if type == "medina"

      line = line.gsub(/\,/,'')
      @chain = "medina"
      @hotel_name = "unknown"
      @currency = "AUD"
      reservation = line[/^[\w]+/]
      dates = line[/\d\d\/\d+\/\d+ - \d+\/\d+\/\d+/]
      checkin_string, checkout_string = dates.split(' - ')
      @checkin_date  = Date.strptime(checkin_string, '%d/%m/%Y')
      @checkout_date = Date.strptime(checkout_string, '%d/%m/%Y')
      payment = line.split(' ')[1][/\d+.\d\d/]
      @commission_paid_aud = payment.to_f
      @guest_name = line[/#{Regexp.escape(payment)}(.*?)#{Regexp.escape(dates)}/m, 1]
      @guest_name.strip!
      @hotel_id = line.strip[-4..-1]
      rest = line[0..-5]
      space_split = rest.split(" ")
      @tax_amount = space_split[-1]
      puts @tax_amount
      net_gst = space_split[-2]
      @gross_commission = net_gst.to_f
      @confirmation_number = line[/#{Regexp.escape(dates)}(.*?)#{Regexp.escape(net_gst)}/m, 1]
      @confirmation_number.strip!
      @statement_date = extras[:payment_date]

      
    end

    if currency == 'AUD'
      @domestic_commission = @commission_less_collector || @commission_paid_aud || 0
    else
      @international_commission = @commission_less_collector || @commission_paid_aud || 0
    end

  end 

  def get_array
    [ 
      @filename,
      @statement_no,
      @statement_date,
      @chain, 
      @hotel_name,
      @hotel_id, 
      @address, 
      @city,
      @country,
      @description,
      @guest_name,
      @agency ,
      @confirmation_number,
      @src ,
      @checkin_date,
      @checkout_date,
      @room_nights,
      @units,
      @status,
      @revenue ,
      @gross_commission,
      @adjust_amount,
      @tax_amount,
      @tax_type,
      @currency,
      @commission_paid_aud,
      @collector_commission,
      @commission_less_collector,
      @domestic_commission,
      @international_commission


    ]
  end

  def compare_names(segment)
  
    def standardise_name(s_name)
      salutations = ["MR", "MRS", "MS", "PROF", "DR", "MISS","REV"]

      s_name.upcase!
      salutations.each do |salutation|
        s_name.gsub!(/#{salutation}$/, '')
      end

      name_arr = s_name.upcase.split(/[\s\/,]/)
      name_arr -= salutations
      name_arr.sort.join
    end

    names1 = standardise_name(@guest_name)
    names2 = standardise_name(segment.guest_name)
    names1.similar(names2)

  end


  def compare_hotel segment
    chain_value = 0
    name_value = 0

   
    def normalise_hotel(name)
      replace_strings = {'B/W' => "BEST WESTERN"}
      generic_strings = ['ON', 'THE', 'HOTEL', ]
      name_arr = name.upcase.split
      name_arr -= generic_strings
      name_arr.each_with_index do |subname, i|
        replace_strings.each do |old_string, new_string|
          if subname == old_string
            name_arr[i] = new_string
          end
        end
      end
      name_arr.sort.join
    end

    statement_hotel = normalise_hotel(@hotel_name)
    segment_hotel = normalise_hotel(segment.hotel_name)
    
    score = statement_hotel.similar(segment_hotel)
    #if score > 80
    #  puts "#{score} #{statement_hotel} #{segment_hotel}"
    #end
    score

  end
     


  def compare_chain(segment)


    def normalise_chain(name)
      #puts name
      name.upcase!
      generic_strings = ["HOTELS", "INTL", "RESORTS", "HOTEL", "INTERNATIONAL", "&"]
      name_arr = name.split 
      name_arr -= generic_strings
      name_arr.sort.join
    end
    
    return -1 unless @chain and segment.chain

    chain1 = normalise_chain(@chain)
    chain2 = normalise_chain(segment.chain)

    return -1 if chain2.similar("UNKOWN") > 90

    chain1.similar(chain2)
  end

  def compare_dates(segment)

    return 100 unless segment.checkout_date.is_a?(Date)
    return 100 unless @checkout_date.is_a?(Date)

    date_diff = (@checkout_date - segment.checkout_date).to_i.abs

  end

  def match_segments(segments)
    #puts @confirmation_number
    matches = []
    segments.each do |segment|

      unless @confirmation_number.nil? || @confirmation_number == "" || 
             segment.confirmation_number.nil? || segment.confirmation_number == ""
        confirmation_match = @confirmation_number.upcase.similar(segment.confirmation_number.upcase)
      else
        confirmation_match = -1
      end 

      guest_name_match = compare_names(segment)    
      chain_match = compare_chain(segment)
      hotel_name_match = compare_hotel(segment)
      date_match = compare_dates(segment)
      match_score = [confirmation_match, guest_name_match, hotel_name_match, date_match, chain_match]

      if confirmation_match > 93 and guest_name_match > 80 and date_match < 5
        matches << ( [0] + get_array + segment.get_array + match_score )
      elsif guest_name_match > 95 and hotel_name_match > 90 and date_match < 3
        matches << ( [1] + get_array + segment.get_array + match_score )
      end

    end

    if matches.length == 0
       matches << get_array
       print "-"
    else
      print "+"
      #puts matches
      matches.sort!
      matches = [matches[0][1..-1]]
      #puts matches
    end
    matches
  end
    
end


def read_mos_commissions(statement_dir)

  segments = []
  puts "Loading the MOS commission data"
  count = 0
  segment_headers = Hash.new()
  
  files = Dir["#{statement_dir}/Hotel Commission*.csv"]
  files.each do |file|
  CSV.foreach( file ) do |row|
    count += 1
    if count == 1
      #puts row
      row.each_with_index do |header, i|
         segment_headers[header] = i
      end
      next
      #puts segment_headers
    end
    seg = Segment.new("mos_commissions", row, segment_headers)
    puts seg.get_array
    segments << seg
  end
  end
  puts "finished reading MOS commission segments there a of total #{count - 1}"
  #puts segments
  segments
end   

def read_mos_segments()

  puts "Loading the MOS Segment Hotel data"
  count = 0
  hotel_segment_count = 0
  segments = []
  segment_headers = Hash.new()
  CSV.foreach( "././#{todays_date}/mos_segments.csv" ) do |row|
    count += 1
    
    if count == 1
      row.each_with_index do |header, i|
         segment_headers[header] = i
      end
      #puts segment_headers
    end
    if "Hotel" == row[segment_headers["segment_type"]]
      hotel_segment_count += 1
      seg = Segment.new("mos_segments", row, segment_headers)
      #puts seg.get_array
      segments << seg
    end
  end
  puts "finished reading MOS segments there a of total #{count - 1}"

  segments
end 

def read_sabre_segments()
  segments = []
  puts "Loading the SAM Segment Hotel data"
  count = 0
  hotel_segment_count = 0
  segment_headers = Hash.new()
  CSV.foreach( "./#{todays_date}/SegmentsForOnyx.csv", :encoding => 'utf-16le:utf-8'  ) do |row|
    count += 1
    if count == 3
      row.each_with_index do |header,i|
        #simple segments file header = "Hotel" if i == 1
        header = "Hotel Id" if i == 2
        segment_headers[header] = i
      end
      #puts segment_headers
    end
    next if count < 4
    
    seg = Segment.new("sabre_segments", row, segment_headers)
    segments  << seg
    #puts seg.get_array
    
  end
  puts "finished reading Sabre segments there a of total #{count - 1}"
  segments
end 


def read_onyx_file(filename)
  
  data = File.read filename

  statements = []
  text = Yomu.read :text, data
  metadata = Yomu.read :metadata, data
  mimetype = Yomu.read :mimetype, data

  period_ending = ""
  count = 0
  onyx_count = 0
  extras = Hash.new()
  text.split("\n").each do |line|
    if line =~ /PERIOD ENDING/
      #PERIOD ENDING - 10/25/2014
      period_ending = line.strip
      extras[:period_ending] = period_ending[0..26]
    elsif line =~ /^[A-Z]/ 
      extras[:chain] = line.gsub('(CONTINUED)', '').strip
      extras[:chain] = extras[:chain].gsub(/-P$/,'')
    elsif line =~ /^  [A-Z]/
      #"Hotel" + line
      blank, hotel_name, address, city = line.split("  ")
      
      extras[hotel_name] = hotel_name
      extras[:address] = address
      city = city || "unknown"
      city = city.gsub('(CONTINUED)','')
      extras[:city] = city
      extras[:hotel_name] = hotel_name

    elsif line =~ /^    [A-Z]/ 
      next if line =~ /GUEST NAME/
      onyx_count += 1
      statements << Statement.new("onyx",  filename, line, extras) 
    end
    count += 1

  end
  puts
  puts "Total total entries in onyx file: #{onyx_count}"
  statements
end




def parse_tacs_hotel_line(line)
  hotel_info = Hash.new()
  hotel_info[:hotel_id], hotel = line.split(') ')
  hotel_info[:hotel_id][0] = ''

  hotel_info[:hotel_name], b = hotel.split(" - ")
  a = b.split(', ')
  hotel_info[:street] = a[0]
  hotel_info[:city] = a[1]
  

  lasta = line.split(', ')[-1]
  hotel_info[:country], currency = lasta.split("(")
  currency[-1] = ''

  hotel_info[:currency] = currency
  return hotel_info
end

def get_commission(text)
  net_payment = 0
  aud_commission = 0
  total_paid = 0
  text.split("\n").each do |line|
    if line =~ /Total Paid/
      #puts line
      text, paid = line.split('Total Paid')
      total_paid = paid.strip.to_f
    elsif line =~ /Customer Service Charge/
      #puts line
      text, aud_comm = line.split('USD')
      aud_commission = aud_comm.strip.to_f
      #puts aud_commission
    elsif line =~ /Net Payment/
      #puts line
      text, payment = line.split("Net Payment")
      net_payment = payment.strip.to_f
      #puts net_payment
    end
  end
  puts "#{total_paid}, #{aud_commission}, #{net_payment}"
  if net_payment == 0
    return 0
  else
    return ( 1 - net_payment/total_paid)
  end

end






def read_tacs_file(filename)
  puts "reading_now"
  puts filename
  data = File.read filename

  statements = []
  text = Yomu.read :text, data
  metadata = Yomu.read :metadata, data
  mimetype = Yomu.read :mimetype, data

  commission_percentage = get_commission(text)
  
  
  count = 0
  tacs_count = 0
  hotel_line =""
  hire_car = false
  extras = Hash.new{}
  extras[:commission_percentage] = commission_percentage
  text.split("\n").each do |line|
    #print line
    if line =~ /Statement No/
      extras[:statement_no] = line.split(' ')[-1]
    elsif line =~ /Payment Date/
      extras[:payment_date] = line.split(' ')[-1]
    elsif line =~ /Payment No/
      extras[:payment_no] = line.split(' ')[-1]
    elsif line =~ /Pick Up/
      hire_car = true
    elsif line =~ /Arrive/
      hire_car = false
    elsif line =~ /^\(/ 
      extras.merge!(parse_tacs_hotel_line(line))
    elsif line =~ /^[A-Z][A-Z]/
      next if hire_car
      statements << Statement.new("tacs", filename, line, extras)  
    elsif line =~ /^[A-Z]/
      #puts line
    end
  end
  statements
end

def read_medina_file(filename)

  data = File.read filename
  text = Yomu.read :text, data
  metadata = Yomu.read :metadata, data
  mimetype = Yomu.read :mimetype, data
  statements = []

  lines = text.split("\n")
  puts lines

  begin
    payment_date = Date.strptime((lines[14].strip), '%d/%m/%Y')
    #puts lines[8]
    raise unless lines[8] =~ /A payment has been remitted to your account as follows :/
    payment = lines[8].split(':')[1].gsub(/[^\d\.]/,'').gsub(/\./,'_')
    raise if payment.empty?
    new_name = "MEDINA_#{payment_date}_P_#{payment}.pdf"
    puts new_name
    #File.rename(filename, new_name )
  rescue
    puts "#{filename} has an invalid file format"
  end
  puts payment_date

  extras = Hash.new {}

  extras[:payment_date] = payment_date

  lines.each_with_index do |line, i|
    if line =~ /\d\d\/\d+\/\d+ - \d+\/\d+\/\d+/
      line = line.gsub(/\,/,'')
      statements << Statement.new("medina", "medina",line, extras)
    end
  end
  statements
end

def read_onyx_files(statement_dir)
  onyx_statements = []
  files = Dir["#{statement_dir}/*219036*.rtf"]
  #puts files
  files.each do |filename|
    onyx_statements.concat( read_onyx_file(filename))
    puts onyx_statements.length
    puts filename
  end
  onyx_statements
end

def read_tacs_files(statement_dir)
  tacs_statements = []
  files = Dir["#{statement_dir}/*_Statement.pdf"]
  files.each do |filename|
    tacs_statements.concat( read_tacs_file(filename))
    puts tacs_statements.length
  end
  tacs_statements
end

def read_medina_files(statement_dir)
  medina_statements = []
  files = Dir["#{statement_dir}/*ELPAYTA*.pdf"]
  print files
  files.each do |filename|
    medina_statements.concat( read_medina_file(filename))
    puts medina_statements.length
  end
  puts medina_statements
  medina_statements
end

def print_csv(file_name, data, header)
  CSV.open(file_name, "w") do |csv_file|
    csv_file << header
    if data.class == Array
      data.each do |line|
        csv_file << line
      end
    elsif data.class == Hash
      data.each do |key, field_data|
        csv_file << field_data
      end
    end
  end
end





def match_ss(segments, statements)
  all_matches = []
  #segments.each do |segment|
  #  all_matches.concat(segment.match(statements))
  #end

  all_matches = []
  puts
  statements.each do |statement|
    all_matches.concat(statement.match_segments(segments))
  end
  
  statement_header =
    [

    "filename",
    "statement_no",
    "statement_date",
    "chain", 
    "hotel_name",
    "hotel_id", 
    "address", 
    "city",
    "country",
    "description",
    "name",
    "agency" ,
    "confirmation_number",
    "src" ,
    "checkin_date",
    "checkout_date",
    "room_nights",
    "units",
    "status",
    "revenue" ,
    "gross_commission",
    "adjust_amount",
    "tax_amount",
    "tax_type",
    "currency",
    "commission_paid_aud",
    "collector_commission",
    "commission_less_collector",
    "domestic_commission",
    "international_commission"
    ]

  segment_header = [
    "type",
    "company", 
    "booking_id",
    "consultant",
    "passenger", 
    "costing_id", 
    "link", 
    "chain",
    "hotel_name", 
    "booking_id",
    "checkin_date", 
    "checkout_date", 
    "rate", 
    "revenue", 
    "currency", 
    "expected_commission", 
    "commission_received",
    "confirmation_number",
    "hotel_id", 
    "gds_code"
    ] 

  scores_header = 
    [
      "confirmation_match", 
      "guest_name_match", 
      "hotel_name_match", 
      "date_match", 
      "chain_match"
    ]

  print_csv("./#{todays_date}/segment_matches#{now_text}.csv", all_matches, 
              statement_header + segment_header + scores_header )

end

def todays_date
  Time.now.strftime("%Y%m%d")
end

def now_text
  Time.now.strftime("%Y%m%d%H%M%S")
end

def parse_files
  statement_dir = "./#{todays_date}"
  mos_segment_headers = Hash.new{}
  segments = []
  #segments.concat(read_mos_segments())
  segments.concat(read_mos_commissions(statement_dir))
  segments.concat(read_sabre_segments())
  puts segments.count
 
  #statement_dir = "./small_files"
  #statement_dir = "./Collectors"
  
  statements = []
  statements.concat(read_medina_files(statement_dir))
  statements.concat(read_onyx_files(statement_dir))
  statements.concat(read_tacs_files(statement_dir))

  match_ss(segments, statements)

end

parse_files
