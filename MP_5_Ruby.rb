
=begin
********************
Last names: Garcia, Meneses, Santos, Telosa
Language: Ruby
Paradigm(s): Object Oriented Programming
********************
=end

# CONSTANT
HOURLY_RATE = 62.5
NON_NIGHT_SHIFT = 0     
NIGHT_SHIFT = 1        
NIGHT_SHIFT_TIME = [2300, 0, 100, 200, 300, 400, 500, 600] 
NSD = 1.10
 
# day shift is from 0900 to 1800  (9AM -> 6PM)
# night shift is from 2200 to 0600  (10 PM -> 6AM)

def displayMainMenu
  print "\n+-------------------------------+"
  puts "\n| === WEEKLY PAYROLL SYSTEM === |" 
  puts "+-------------------------------+"
  puts "| (1) Modify configuration      |"
  puts "| (2) Generate Payroll          |"
  puts "| (3) Exit the program          |"
  puts "+-------------------------------+"
  print "Choose option: "
end

class Weekday

  attr_accessor :dailySalary, :inTime, :outTime, :dayType, :overtime, :nightShift

  def initialize(inTime=900, outTime=900, dayType="Normal Day")    
    @dailySalary = 500
    @inTime = inTime
    @outTime = outTime 
    @dayType = dayType
    @overtime = 0
    @nightShift = 0
  end

  def additionalPay
    if (@inTime == 900 && @outTime > 2200) || (@inTime == 900 && NIGHT_SHIFT_TIME.include?(@outTime))
      @overtime = 4
    elsif(@inTime == 900 && @outTime > 1800) && (@inTime == 900 && @outTime < 2200)
      @overtime = (@outTime - 1800) % 1000 / 100
    end
    
    if NIGHT_SHIFT_TIME.include?(@outTime)                  #11PM, 12AM, 1AM -> 6AM
      @nightShift = NIGHT_SHIFT_TIME.index(@outTime) + 1
    end
  end

  def to_s
    puts "+-------------------------------+"
    puts "| Daily Salary: #{@dailySalary}"

    if inTime == 0
      puts "| In Time: 0000"
    elsif inTime < 1000
      puts "| In Time: 0" + "#{@inTime}"
    else
      puts "| In Time: #{@inTime}"
    end

    if outTime == 0
      puts "| Out Time: 0000"
    elsif outTime < 1000
      puts "| Out Time: 0" + "#{@outTime}"
    else
      puts "| Out Time: #{@outTime}"
    end

    puts "| Day Type: #{@dayType}"
    puts "| Overtime: #{@overtime}"
    puts "| Night Shift: #{@nightShift}"
    print "+-------------------------------+"
  end
end

class Employee

  attr_accessor :name

  @@employees = []

  def initialize (name)
    @name = name
    @weekday = Array.new(7) { Weekday.new }
    @@employees << self
  end

  # def add_weekday(day, weekday)                                          # NOTE - function not being used     
  #   @weekday[day - 1] = weekday if day >= 1 && day <= 7
  # end

  def weekdayReturn(day)
    @weekday[day - 1]
  end

  def self.findEmployee (name)
    @@employees.find { |employee| employee.name == name }                  # NOTE - typo in the comparison (= -> ==)
  end
end

def findEmployee (employees, name)                                         # NOTE - Modified function for findEmployee 
  for employee in employees
    if employee.name == name
        return 1
    end
  end
  return 0
end

def returnEmployee (employees, name)                                      # NOTE - Added case where employee not found
  for employee in employees
    if employee.name == name
      return employee
    end
   end
   return nil
end

def rest_holiday_rate (type)                                             # NOTE - Followed syntax from specs; Replaced 'and' by comma 
  case type
  when "Rest Day"
    return 1.30
  when "SNWH"
    return 1.30
  when "SNWH, Rest Day"
    return 1.50
  when "Regular Holiday"
    return 2.00
  when  "Regular Holiday, Rest Day"
    return 2.60
  end
end

def overtime_rate (type, is_shift)
  if is_shift == NON_NIGHT_SHIFT
    case type
    when "Normal Day"
      return 1.25
    when "Rest Day"
      return 1.69
    when "SNWH"
      return 1.69
    when "SNWH, Rest Day"
      return 1.95
    when "Regular Holiday"
      return 2.60
    when  "Regular Holiday, Rest Day"
      return 3.38
    end
  elsif is_shift == NIGHT_SHIFT
    case type
    when "Normal Day"
      return 1.375
    when "Rest Day"
      return 1.869
    when "SNWH"
      return 1.859
    when "SNWH, Rest Day"
      return 2.145
    when "Regular Holiday"
      return 2.860
    when  "Regular Holiday, Rest Day"
      return 3.718
    end
  end
end

# program proper

employees = []
isConfigShown = false;

loop do
  displayMainMenu
  choice = gets.chomp.to_i

  case choice
  # input
  when 1
    print "\n+------------------------------+"
    puts  "\n| === Modify configuration === |"
    puts    "+------------------------------+"
    print "Enter employee name: "
    name = gets.chomp.to_s

    if findEmployee(employees, name) == 0
      employees << Employee.new(name)
      puts "new employee!"
    end

    if findEmployee(employees, name) == 1
      employee = returnEmployee(employees, name)
      if employee.nil?
        puts "Employee not found!"
      else
        puts "Default configuration:"

        for day in 1..7 do
          weekday = employee.weekdayReturn(day-1)
          if isConfigShown == false
            puts weekday.to_s
            isConfigShown = true
          end

          puts "\nModifying attributes for day #{day} of Employee: #{employee.name}:\n"
          
          print "Enter IN Time: " 
          weekday.inTime = gets.chomp.to_i

          print "Enter OUT Time: "
          weekday.outTime = gets.chomp.to_i
          
          if weekday.inTime != weekday.outTime
            print "Enter Day Type: "
            weekday.dayType = gets.chomp
          elsif weekday.inTime == weekday.outTime && (day != 6 || day != 7)
            weekday.dayType = "Absent"
          elsif weekday.inTime == weekday.outTime && (day == 6 || day == 7)
            weekday.dayType = "Rest Day"
          end
          
          weekday.additionalPay
          # puts "\nModified day #{day} for Employee: #{employee.name}"
          # puts weekday.to_s
        end
      end
    end
  
  # computation
  when 2
    print "\n+------------------------------+"
    puts  "\n|   === Generate Payroll ===   |"
    puts    "+------------------------------+"
    print "Enter employee name: "
    name = gets.chomp

    if findEmployee(employees, name) == 1
      employee = returnEmployee(employees, name)
      weeklySalary = 0
      for i in 0..6 do
        weekday = employee.weekdayReturn(i)                                                      
        print weekday.to_s
        salary = weekday.dailySalary
        
        # employee went to work
        if weekday.inTime == 900 && weekday.outTime != 900
          if weekday.dayType == "Normal Day"
            if weekday.overtime > 0
              salary += weekday.overtime * HOURLY_RATE * overtime_rate(weekday.dayType, 0)     
            end
            
            if weekday.nightShift > 0
              salary += weekday.nightShift * HOURLY_RATE * overtime_rate(weekday.dayType, 1)
            end

          elsif weekday.dayType != "Normal Day"
            salary = salary * rest_holiday_rate(weekday.dayType)
            if weekday.overtime > 0
              salary += weekday.overtime * HOURLY_RATE * overtime_rate(weekday.dayType, 0)
            end
            
            if weekday.nightShift > 0
              salary += weekday.nightShift * HOURLY_RATE * overtime_rate(weekday.dayType, 1)
            end
          end

        # employee did not go to work
        # either they were absent or it was their rest day
        elsif weekday.inTime == 900 && weekday.outTime == 900
          if i == 5 || i == 6 # rest day
            salary = weekday.dailySalary;
          else                # absent
            salary -= salary
          end

        # work on a night shift schedule not the regular working hours
        elsif weekday.inTime == 1800
          salary += weekday.nightShift * HOURLY_RATE * NSD
        end

        weeklySalary += salary
        printf "\nDay #{i+1}: " + '%.2f' % salary + "\n\n"
      end
      puts "TOTAL WEEKLY SALARY: #{weeklySalary}"
    else
      puts "Employee not found!"
    end

  # Terminate
  when 3
    print "\n+------------------------------+"
    puts  "\n|   === Exit the program ===   |"
    puts    "+------------------------------+"
    break
  else
    puts "\n!!! invalid option !!!"
  end
end


    # debugging
    # weekday = employee.weekdayReturn(0)
    #-----
    #   puts weekday.to_s
    #   salary = weekday.dailySalary
    #   if weekday.dayType == "Normal Day"
    #     if weekday.overtime > 0
    #       salary += weekday.overtime * HOURLY_RATE * overtime_rate(weekday.dayType, 0)
    #     end
    #-----   
    #     if weekday.nightShift > 0
    #       salary += weekday.nightShift * HOURLY_RATE * overtime_rate(weekday.dayType, 1)
    #     end
    #   elsif weekday.dayType != "Normal Day"
    #     salary = salary * rest_holiday_rate(weekday.dayType)
    #     if weekday.overtime > 0
    #       salary += weekday.overtime * HOURLY_RATE * overtime_rate(weekday.dayType, 0)
    #     end
    #-----
    #     if weekday.nightShift > 0
    #       salary += weekday.nightShift * HOURLY_RATE * overtime_rate(weekday.dayType, 1)
    #     end
    #   end 
    #-----
    #   i = 1
    #   printf "\nDay #{i+1}: " + '%.2f' % salary
