require 'pry'
require_relative 'trip.rb'
require_relative 'user.rb'

module RideShare
  class Driver < User
    attr_reader :id, :name, :vin, :phone, :driven_trips, :trips
    attr_accessor :status

    def initialize(id: 0, name: "", vin: "", phone:"", trips: [], status: :AVAILABLE, driven_trips: [])
      raise ArgumentError.new("Bad ID Value") if id <= 0
      raise ArgumentError.new("Invalid VIN number") if vin.empty? || vin.length != 17

      @id = id
      @name = name
      @vin = vin
      @phone = phone
      @trips = trips
      @status = status
      @driven_trips = driven_trips
    end

    def add_driven_trip(trip)
      if trip.class == RideShare::Trip
        @driven_trips << trip
      else
        raise ArgumentError, 'Trip is not provided'
      end
    end

    def average_rating
      result = 0
      if @driven_trips == []
        return 0
      else
        @driven_trips.each do |trip|
          result += trip.rating if trip.rating != nil
        end
        return (result.to_f / @driven_trips.length).round(2)
      end
    end

    def total_revenue
      total_revenue = 0

      if @driven_trips != []
        @driven_trips.each do |trip|
          total_revenue += 0.8 * (trip.cost - 1.65) if trip.cost != nil
        end
      end
      
      return total_revenue.round(2)
    end

    def net_expenditures
      made_as_driver = total_revenue
      spent_as_passenger = super
      net_earnings = spent_as_passenger - made_as_driver

      return net_earnings.round(2)
    end

    def in_progress_trip(trip, driver)
      @driven_trips << trip

      driver.status = :UNAVAILABLE
    end
  end
end
