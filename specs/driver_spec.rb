require_relative 'spec_helper'

describe "Driver class" do

    describe "Driver instantiation" do
      before do
        @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
          vin: "1C9EVBRM0YBC564DZ",
          phone: '111-111-1111',
          status: :AVAILABLE)
      end

      it "is an instance of Driver" do
        expect(@driver).must_be_kind_of RideShare::Driver
      end

      it "throws an argument error with a bad ID value" do
        expect{ RideShare::Driver.new(id: 0, name: "George", vin: "33133313331333133")}.must_raise ArgumentError
      end

      it "throws an argument error with a bad VIN value" do
        expect{ RideShare::Driver.new(id: 100, name: "George", vin: "")}.must_raise ArgumentError
        expect{ RideShare::Driver.new(id: 100, name: "George", vin: "33133313331333133extranums")}.must_raise ArgumentError
      end

      it "sets driven trips to an empty array if not provided" do
        expect(@driver.driven_trips).must_be_kind_of Array
        expect(@driver.driven_trips.length).must_equal 0
      end

      it "is set up for specific attributes and data types" do
        [:id, :name, :vin, :status, :driven_trips].each do |prop|
          expect(@driver).must_respond_to prop
        end

        expect(@driver.id).must_be_kind_of Integer
        expect(@driver.name).must_be_kind_of String
        expect(@driver.vin).must_be_kind_of String
        expect(@driver.status).must_be_kind_of Symbol
      end
    end

    describe "add_driven_trip method" do
      before do
        pass = RideShare::User.new(id: 1, name: "Ada", phone: "412-432-7640")
        @driver = RideShare::Driver.new(id: 3, name: "Lovelace", vin: "12345678912345678")
        @trip = RideShare::Trip.new(id: 8, driver: @driver, passenger: pass, start_time: Time.parse("2016-08-08"),
        end_time: Time.parse("2018-08-09"), rating: 5)
      end

      it "throws an argument error if trip is not provided" do
        expect{ @driver.add_driven_trip(1) }.must_raise ArgumentError
      end

      it "increases the trip count by one" do
        previous = @driver.driven_trips.length
        @driver.add_driven_trip(@trip)
        expect(@driver.driven_trips.length).must_equal previous + 1
      end
    end

    describe "average_rating method" do
      before do
        @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                        vin: "1C9EVBRM0YBC564DZ")
        trip = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
                                   start_time: Time.parse("2016-08-08"),
                                   end_time: Time.parse("2016-08-08"), rating: 5)
        @driver.add_driven_trip(trip)
      end

      it "returns a float" do
        expect(@driver.average_rating).must_be_kind_of Float
      end

      it "returns a float within range of 1.0 to 5.0" do
        average = @driver.average_rating
        expect(average).must_be :>=, 1.0
        expect(average).must_be :<=, 5.0
      end

      it "returns zero if no driven trips" do
        driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                       vin: "1C9EVBRM0YBC564DZ")
        expect(driver.average_rating).must_equal 0
      end

      it "correctly calculates the average rating" do
        trip2 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
                                    start_time: Time.parse("2016-08-08"),
                                    end_time: Time.parse("2016-08-09"),
                                    rating: 1)
        @driver.add_driven_trip(trip2)

        expect(@driver.average_rating).must_be_close_to (5.0 + 1.0) / 2.0, 0.01
      end


    end

  describe "total_revenue" do
    before do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                      vin: "1C9EVBRM0YBC564DZ")
      trip_1 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
                                 start_time: Time.parse("2016-08-08"),
                                 end_time: Time.parse("2016-08-09"), rating: 5, cost: 16.75)
      trip_2 = RideShare::Trip.new(id: 9, driver: @driver, passenger: nil,
                                start_time: Time.parse("2016-08-08"),
                                end_time: Time.parse("2016-08-09"), rating: 5, cost: 30)
      trip_3 = RideShare::Trip.new(id: 10, driver: @driver, passenger: nil,
                                start_time: Time.parse("2016-08-08"),
                                end_time: Time.parse("2016-08-09"), rating: 5, cost: 18.95)
      @driver.add_driven_trip(trip_1)
      @driver.add_driven_trip(trip_2)
      @driver.add_driven_trip(trip_3)
    end

    it "accurately calculates the revenue for driver" do
      expect(@driver.total_revenue).must_equal 48.60
    end
  end

  describe "net_expenditures" do
    it "will calculate the net expenditures for a driver" do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                      vin: "1C9EVBRM0YBC564DZ")
      trip_1 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
                                 start_time: Time.parse("2016-08-08"),
                                 end_time: Time.parse("2016-08-09"), rating: 5, cost: 16.75)
      trip_2 = RideShare::Trip.new(id: 9, driver: @driver, passenger: nil,
                                start_time: Time.parse("2016-08-08"),
                                end_time: Time.parse("2016-08-09"), rating: 2, cost: 30)
      trip_3 = RideShare::Trip.new(id: 54, driver: 10, passenger: nil,
                                start_time: Time.parse("2016-08-08"),
                                end_time: Time.parse("2016-08-09"), rating: 4, cost: 18.95)
      trip_4 = RideShare::Trip.new(id: 54, driver: 14, passenger: nil,
                                  start_time: Time.parse("2016-08-08"),
                                  end_time: Time.parse("2016-08-09"), rating: 3, cost: 16.73)
      @driver.add_driven_trip(trip_1)
      @driver.add_driven_trip(trip_2)
      @driver.add_trip(trip_3)
      @driver.add_trip(trip_4)

      expect(@driver.net_expenditures).must_equal 0.92
    end

    it "will return only earnings when driver has taken zero trips" do
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                      vin: "1C9EVBRM0YBC564DZ")
      trip_1 = RideShare::Trip.new(id: 8, driver: @driver, passenger: nil,
                                 start_time: Time.parse("2016-08-08"),
                                 end_time: Time.parse("2016-08-09"), rating: 5, cost: 16.75)
      trip_2 = RideShare::Trip.new(id: 9, driver: @driver, passenger: nil,
                                start_time: Time.parse("2016-08-08"),
                                end_time: Time.parse("2016-08-09"), rating: 2, cost: 30)
      @driver.add_driven_trip(trip_1)
      @driver.add_driven_trip(trip_2)

      expect(@driver.net_expenditures).must_equal (-1 * 34.76)
    end

  end
end
