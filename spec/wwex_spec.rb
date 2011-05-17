require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module WWEX
  describe RateMatrix do
    before(:each) do
      @acct_number = "100880967"
      @from_zip    = 20500
      @to_zip      = 90210
    end
    
    describe "#rates" do
      context "using a flat-rate envelope" do
        before(:each) do
          FakeWeb.register_uri(:any, 'http://www.wwexship.com/rates/GetRates.jsp?toZip=20500&fromZip=90210&acctNum=100880967', :body => File.join(File.dirname(__FILE__), 'fixtures', 'rate_matrix.csv'))
        end
        
        it "should return a hash of rates" do
          WWEX::RateMatrix.rates(@acct_number, @from_zip, @to_zip).should be_an_instance_of(Hash)
        end
      
        it "should include a Ground rate (GND)" do
          WWEX::RateMatrix.rates(@acct_number, @from_zip, @to_zip).should include("GND")
        end
      
        it "should include a Next Day Air Saver rate (NAS)" do
          WWEX::RateMatrix.rates(@acct_number, @from_zip, @to_zip).should include("NAS")
        end
      
        it "should include a Next Day Air rate (EXP)" do
          WWEX::RateMatrix.rates(@acct_number, @from_zip, @to_zip).should include("EXP")
        end
      
        it "should have a EXP value of $17.94" do
          WWEX::RateMatrix.rates(@acct_number, @from_zip, @to_zip)["EXP"].should == "17.94"
        end
        
        it "should return nil for GND" do
          WWEX::RateMatrix.rates(@acct_number, @from_zip, @to_zip)["GND"].should == nil
        end
      end
      
      context "using other packaging" do
        before(:each) do
          @weight = 1
          FakeWeb.register_uri(:any, 'http://www.wwexship.com/rates/GetRates.jsp?toZip=20500&fromZip=90210&acctNum=100880967&weight=1', :body => File.join(File.dirname(__FILE__), 'fixtures', 'rate_matrix_weight.csv'))
        end
        
        it "should have a value for GND" do
          WWEX::RateMatrix.rates(@acct_number, @from_zip, @to_zip, @weight)["GND"].should_not == nil
        end
      end
    end
    
    describe "#expanded_rates" do
      context "using a flat-rate envelope" do
        before(:each) do
          FakeWeb.register_uri(:any, 'http://www.wwexship.com/rates/GetWWERates.jsp?toZip=20500&fromZip=90210&acctNum=100880967&weight=0', :body => File.join(File.dirname(__FILE__), 'fixtures', 'expanded_rate_matrix.csv'))
        end
        
        it "should return a hash of values" do
          WWEX::RateMatrix.expanded_rates(@acct_number, @from_zip, @to_zip).should be_an_instance_of(Hash)
        end
      end
    end
  end
end