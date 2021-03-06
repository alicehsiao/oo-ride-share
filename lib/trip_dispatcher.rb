require 'csv'
require 'time'
require 'awesome_print'
require 'pry'

require_relative 'user'
require_relative 'trip'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :trips, :passengers

    def initialize(user_file = 'support/users.csv',
                   trip_file = 'support/trips.csv',
                    driver_file = 'support/drivers.csv')
      @passengers = load_users(user_file)
      @drivers = load_drivers(driver_file)
      @trips = load_trips(trip_file)
    end

    def load_users(filename)
      users = []

      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        users << User.new(input_data)
      end

      return users
    end

    def load_drivers(filename)
      drivers = []

      driver_data = CSV.open(filename, 'r', headers: true, header_converters: :symbol)

      driver_data.each do |raw_driver|
        user = find_passenger(raw_driver[:id].to_i)

        parsed_trip = {
          id: user.id,
          name: user.name,
          vin: raw_driver[:vin],
          phone: user.phone_number,
          status: raw_driver[:status].to_sym,
        }

        driver = Driver.new(parsed_trip)
        @passengers.each_with_index do |person, i|
            if person.id == driver.id
              @passengers[i] = driver
            end
          end

        drivers << driver
      end

      return drivers
    end


    def load_trips(filename)
      trips = []
      trip_data = CSV.open(filename, 'r', headers: true, header_converters: :symbol)

      trip_data.each do |raw_trip|
        passenger = find_passenger(raw_trip[:passenger_id].to_i)
        driver = find_driver(raw_trip[:driver_id].to_i)

        parsed_trip = {
          id: raw_trip[:id].to_i,
          passenger: passenger,
          start_time: Time.parse(raw_trip[:start_time]),
          end_time: Time.parse(raw_trip[:end_time]),
          cost: raw_trip[:cost].to_f,
          rating: raw_trip[:rating].to_i,
          driver: driver
        }

        trip = Trip.new(parsed_trip)

        passenger.add_trip(trip)
        driver.add_driven_trip(trip)

        trips << trip
      end

      return trips
    end

    def find_passenger(id)
      check_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    def find_driver(id)
      check_id(id)
      return @drivers.find {|driver| driver.id == id}
    end

    def check_driver_availability_and_assign(user_id)
      passenger = find_passenger(user_id)
      all_available_drivers = @drivers.find_all {|driver| driver.status == :AVAILABLE}
      new_available_drivers = all_available_drivers.dup

      new_available_drivers.each do |instance|
        if instance == passenger
         new_available_drivers.delete(instance)
        end
      end

      if new_available_drivers == []
        raise ArgumentError.new("No Available Drivers. Try later.")
      else
        driver = new_available_drivers[0]
        new_available_drivers.each_with_index do |instance, index|
          if instance.driven_trips == []
            driver = new_available_drivers[index]
          end
        end
      end

      return driver
    end

    def request_trip(user_id)
      passenger = find_passenger(user_id)
      driver = check_driver_availability_and_assign(user_id)

      new_trip = RideShare::Trip.new(id: driver.id, passenger: passenger, driver: driver, start_time: Time.now, end_time: nil, cost: nil, rating: nil)

      driver.in_progress_trip(new_trip, driver)
      passenger.add_trip(new_trip)

      @trips << new_trip

      return new_trip
    end

    def inspect
      return "#<#{self.class.name}:0x#{self.object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    private

    def check_id(id)
      raise ArgumentError, "ID cannot be blank or less than zero. (got #{id})" if id.nil? || id <= 0
    end
  end
end
