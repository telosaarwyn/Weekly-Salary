/********************
Last names: Garcia, Meneses, Santos, Telosa
Language: Go
Paradigm(s): Functional
********************/

package main

import "fmt"

func countTime(inTime int, outTime int) []int {
	hours := []int{}
	time := inTime
	work := 0
	nwork := 0
	ot := 0
	nsot := 0

	if time == outTime {
		hours = append(hours, work, ot, nsot)
		return hours
	}

	for time != outTime {
		if work < 9 && (time >= 601 && time <= 2199) {
			work++
		} else if work < 9 && (time >= 2200 || time < 600) {
			nwork++
		} else if work >= 9 && (time >= 601 && time <= 2199) {
			work++
			ot++
		} else if work >= 9 && (time >= 2200 || time < 600) {
			work++
			nsot++
		}
		time = (time + 100) % 2400
	}
	hours = append(hours, work, nwork, ot, nsot)
	return hours
}

func computeDay(rate float32, inTime int, outTime int, dayType int, restDay int) float32 {
	var salary float32 = rate
	salaryRate := dayRate(dayType, restDay)
	hours := countTime(inTime, outTime)

	if hours[1] == 0 {
		salary = rate * salaryRate
	} else {
		salary = (rate / 8) * float32(hours[0]-1)
		salary += (((rate / 8) + (rate / 8 * 0.1)) * float32(hours[1]))
	}

	if hours[0] == 0 {
		print("Did Not attend Today\n")
		return 0
	}

	otRate := overTimeRate(dayType, restDay, 0)
	ot := (rate / 8) * float32(hours[2]) * otRate
	nsotRate := overTimeRate(dayType, restDay, 1)
	nsot := (rate / 8) * float32(hours[3]) * nsotRate

	salary += ot + nsot

	dayTypes := []string{"Normal Day", "SNWH", "Regular Holiday"}
	restDays := []string{"", ", RestDay"}
	fmt.Printf("Daily Rate: %v\n", rate)
	fmt.Printf("IN Time: %v\n", inTime)
	fmt.Printf("OUT Time: %v\n", outTime)
	fmt.Printf("Day Type: %v%v\n", dayTypes[dayType-1], restDays[restDay])
	if hours[1] > 0 {
		fmt.Printf("Hours on Night Shift: %v\n", hours[1])
	}
	fmt.Printf("Hours OverTime (Night Shift OverTime): %v(%v)\n", hours[2], hours[3])
	fmt.Printf("Salary of the day: %v\n", salary)
	fmt.Println("Computation:")

	if dayType > 1 || restDay == 1 {
		fmt.Printf("Daily Rate = %v * %v\n", rate, salaryRate)
	} else {
		fmt.Printf("Daily Rate: %v\n", rate)
	}
	if hours[1] > 0 {
		fmt.Printf("Hours on NS x Hourly Rate x NSD\n")
		fmt.Printf("%v * %v * %v / 8 + 10%%\n", hours[1], rate, salaryRate)
	}
	if hours[2] > 0 {
		fmt.Printf("Hours OT x OT Rate\n")
		fmt.Printf("%v * %v * %v / 8 * %v = %v\n", hours[2], rate, salaryRate, otRate, ot)
	}

	if hours[3] > 0 {
		fmt.Printf("Hours NS-OT x OT Rate\n")
		fmt.Printf("%v * %v * %v / 8 * %v = %v\n", hours[3], rate, salaryRate, nsotRate, nsot)
	}

	return salary
}

func dayRate(i int, restDay int) float32 {
	if restDay == 0 {
		if i == 1 {
			return 1.0
		} else if i == 2 {
			return 1.3
		} else {
			return 2.0
		}
	} else {
		if i == 1 {
			return 1.3
		} else if i == 2 {
			return 1.5
		} else {
			return 2.60
		}
	}
}

func overTimeRate(dayType int, restDay int, nightShift int) float32 {
	if nightShift == 0 {
		if dayType == 1 && restDay == 0 {
			return 1.25
		} else if dayType == 1 && restDay == 1 {
			return 1.69
		} else if dayType == 2 && restDay == 0 {
			return 1.69
		} else if dayType == 2 && restDay == 1 {
			return 1.95
		} else if dayType == 3 && restDay == 0 {
			return 2.60
		} else if dayType == 3 && restDay == 1 {
			return 3.38
		}
	} else {
		if dayType == 1 && restDay == 0 {
			return 1.375
		} else if dayType == 1 && restDay == 1 {
			return 1.859
		} else if dayType == 2 && restDay == 0 {
			return 1.859
		} else if dayType == 2 && restDay == 1 {
			return 2.145
		} else if dayType == 3 && restDay == 0 {
			return 2.86
		} else if dayType == 3 && restDay == 1 {
			return 3.718
		}
	}

	return 0
}

func main() {
	var shiftNumber int

	fmt.Print("Daily Rate:")
	var rate float32
	fmt.Scan(&rate)

	if rate < 500 {
		fmt.Println("You entered low salary will make 500 as daily rate")
		rate = 500.0
	}

	fmt.Print("Number of Work Days:")
	fmt.Scan(&shiftNumber)

	var inTime int
	var dayType int
	var outTime int
	var inTimes []int
	var dayTypes []int
	var outTimes []int

	for i := 1; i <= 7; i++ {
		fmt.Printf("day: %v\n", i)
		fmt.Print("In Time:")
		fmt.Scan(&inTime)
		fmt.Print("Time Out:")
		fmt.Scan(&outTime)
		fmt.Print("1. Normal Day  2. Special Non-Working Day 3. Regular Holiday :")
		fmt.Scan(&dayType)
		inTimes = append(inTimes, inTime)
		outTimes = append(outTimes, outTime)
		dayTypes = append(dayTypes, dayType)
	}

	var salary []float32

	for i := 1; i < shiftNumber; i++ {
		fmt.Printf("\nDay %v\n", i)
		salary = append(salary, computeDay(rate, inTimes[i-1], outTimes[i-1], dayTypes[i-1], 0))
	}

	for i := shiftNumber + 1; i <= 7; i++ {
		fmt.Printf("\nDay %v\n", i)
		salary = append(salary, computeDay(rate, inTimes[i-1], outTimes[i-1], dayTypes[i-1], 1))
	}

	weekSalary := float32(0)
	for i := 0; i < 7; i++ {
		weekSalary += salary[i]
	}

	fmt.Printf("\nTotal Salary %v\n", weekSalary)
}
