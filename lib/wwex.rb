require 'httparty'
require 'fastercsv'

module WWEX
  class RateMatrix
    include HTTParty
    base_uri 'http://www.wwexship.com'
    
    SHIPPINGLOGIC_TO_WWEX_MAPPINGS = {
      "03" => "GND",
      "13" => "NAS",
      "65" => "SDS",
      "01" => "EXP"
    }
    
    def self.rates(acct_number, to_zip, from_zip, weight = nil)
      query = {:acctNum => acct_number, :toZip => to_zip, :fromZip => from_zip, :weight => weight}.delete_if {|k,v| v.nil?}
      parse_response(get('/rates/GetRates.jsp', :query => query).parsed_response)
    end
    
    def self.expanded_rates(acct_number, to_zip, from_zip, weight = 0)
      query = {:acctNum => acct_number, :toZip => to_zip, :fromZip => from_zip, :weight => weight}.delete_if {|k,v| v.nil?}
      parse_response(get('/rates/GetWWERates.jsp', :query => query).parsed_response)
    end
    
    private
    def self.parse_response(response)
      na_converter = Proc.new { |v| v == "N/A" ? nil : v }
      rates = FasterCSV.parse(response.strip.gsub(/<br *\/*>\r\n|[ ]|\$/,''), {:skip_blanks => true, :headers => true, :converters => na_converter})
      rates.first.to_hash
    end
  end
end