class Car < ActiveRecord::Base
  attr_accessible :color, :brand
  belongs_to :user

  def self.count_by_colors
    rows = connection.execute(<<-SQL)
      SELECT color AS COLOR, COUNT(*) AS count
      FROM cars
      GROUP BY color
    SQL
    rows.each_with_object({}) { |acc, row| acc[row['color']] = row['count'] }
  end
end

class Organisation < ActiveRecord::Base
  has_many :users

end

class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name
  has_many :cars

  def self.users_with_red_cars
    car_ids = Car.where(color: 'red').pluck(:id)
    User.joins(:cars).where(cars: { id: car_ids }).to_a
  end
end

class UserController < ActionController::Base

  def show
    @user = User.where("id = #{params[:id]}").to_a.first
    render @user
  end

  def print_users_with_red_cars
    User.users_with_red_cars.each do |user|
      puts user.first_name + ' ' + user.last_name + ' has a red car'
    end
  end

  def red_brands
    results = []
    User.users_with_red_cars.each do |user|
      user.cars.each { |car| results << car.brand if car.color == 'red' && !results.include?(car.brand) }
    end
    render json: results.to_json
  end
end