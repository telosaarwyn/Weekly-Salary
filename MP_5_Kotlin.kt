/********************
Last names: Garcia, Meneses, Santos, Telosa
Language: Kotlin
Paradigm(s): Functional
 ********************/

import java.util.*

fun countTime(inTime: Int, outTime: Int):MutableList<Int>{
    var hours = mutableListOf<Int>()
    var time = inTime
    var work:Int = 0
    var nwork:Int = 0
    var ot:Int = 0
    var nsot:Int = 0

    if (time == outTime){
        hours.add(work)
        hours.add(ot)
        hours.add(nsot)
        return hours
    }

    while(time != outTime) {
        if (work < 9 && (time in 601..2199)){
            work++
        }else if (work < 9 && (time >= 2200 || time < 600)){
            nwork++
        }else if(work >= 9 && (time in 601..2199)){
            work++
            ot++
        }else if (work >= 9 && (time >= 2200 || time < 600)){
            work++
            nsot++
        }
        time = (time + 100) % 2400
    }
    hours.add(work)
    hours.add(nwork)
    hours.add(ot)
    hours.add(nsot)
    return hours
}

fun computeDay(rate:Float, inTime:Int, outTime:Int, dayType:Int, restDay: Int):Float{
    var salary:Float = rate
    var salaryRate = dayRate(dayType, restDay)
    var hours = countTime(inTime, outTime)

    //compute
    if(hours[1] == 0){
        salary = rate * salaryRate
    }else {
        salary = (rate / 8) * (hours[0]-1)
        salary += (((rate / 8) + (rate / 8 * 0.1f)) * hours[1])
    }

    if(hours[0] == 0){
        println("Did Not Attend Today")
        return 0f
    }

    //over time
    var otRate = overTimeRate(dayType, restDay, 0)
    var ot = (rate/8) * hours[2] * otRate
    var nsotRate = overTimeRate(dayType, restDay, 1)
    var nsot = (rate/8) * hours[3] * nsotRate

    salary += ot + nsot

    //print output
    val dayTypes = listOf("Normal Day", "SNWH", "Regular Holiday")
    val restDays = listOf("", ", RestDay")
    println("Daily Rate: ${rate}")
    println("IN Time: ${inTime}")
    println("OUT Time: ${outTime}")
    println("Day Type: ${dayTypes[dayType-1]}${restDays[restDay]}")
    if(hours[1] > 0){
        println("Hours on Night Shift: ${hours[1]}")
    }
    println("Hours OverTime (Night Shift OverTime): ${hours[2]}(${hours[3]})")
    println("Salary of the day: ${salary}")
    println("Computation:")

    if(dayType > 1 || restDay == 1){
        println("Daily Rate = ${rate} * ${salaryRate}")
    }else{
        println("Daily Rate: ${rate}")
    }
    if(hours[1] > 0){
        println("Hours on NS x Hourly Rate x NSD")
        println("${hours[1]} * ${rate * salaryRate} / 8 + 10%")
    }
    if (hours[2] > 0){
        println("Hours OT x OT Rate")
        println("${hours[2]} * ${rate * salaryRate} / 8 * ${otRate} = ${ot}")
    }

    if (hours[3] > 0){
        println("Hours NS-OT x OT Rate")
        println("${hours[3]} * ${rate * salaryRate} / 8 * ${nsotRate} = ${nsot}")
    }

    return salary
}

fun dayRate(i:Int, restDay:Int):Float{
    if (restDay == 0){//not restday
        if (i == 1){//normal
            return 1.0f
        }else if(i == 2){//SNWH
            return 1.3f
        }else{//regular holiday
            return 2.0f
        }
    }else {
        if (i == 1) {//rest day
            return 1.3f
        } else if (i == 2) {//restday + SNWH
            return 1.5f
        } else {//rest day + regular holiday
            return 2.60f
        }
    }
}

fun overTimeRate(dayType:Int, restDay:Int, nightShift:Int):Float{
    if (nightShift == 0){
        if(dayType == 1 && restDay == 0){
            return 1.25f
        }else if (dayType == 1 && restDay == 1){
            return 1.69f
        }else if (dayType == 2 && restDay == 0){
            return  1.69f
        }else if (dayType == 2 && restDay == 1){
            return  1.95f
        }else if (dayType == 3 && restDay == 0){
            return 2.60f
        }else if (dayType == 3 && restDay == 1){
            return 3.38f
        }
    }else {
        if(dayType == 1 && restDay == 0){
            return 1.375f
        }else if (dayType == 1 && restDay == 1){
            return 1.859f
        }else if (dayType == 2 && restDay == 0){
            return 1.859f
        }else if (dayType == 2 && restDay == 1){
            return 2.145f
        }else if (dayType == 3 && restDay == 0){
            return 2.86f
        }else if (dayType == 3 && restDay == 1){
            return 3.718f
        }
    }

    return 0f
}

fun main(args: Array<String>) {
    var shiftNumber:Int

    print("Daily Rate:")
    val sc = Scanner(System.`in`)
    var rate:Float = sc.nextFloat()

    if(rate < 500){//default
        println("You entered low salary will make 500 as daily rate")
        rate = 500.0f
    }

    print("Number of Work Days:")
    shiftNumber = sc.nextInt()

    var inTime:Int // day or night
    var dayType:Int // normal|SNWH|Regular Holiday
    var outTime:Int // hours over time
    var inTimes = mutableListOf<Int>()
    var dayTypes = mutableListOf<Int>()
    var outTimes = mutableListOf<Int>()

    for (i in 1..7){
        println("day: ${i}")
        print("In Time:")
        inTime = sc.nextInt()
        print("Time Out:")
        outTime = sc.nextInt()
        print("1. Normal Day  2. Special Non-Working Day 3. Regular Holiday :")
        dayType = sc.nextInt()
        inTimes.add(inTime)
        outTimes.add(outTime)
        dayTypes.add(dayType)
    }

    var salary = mutableListOf<Float>()

    //compute normal days
    for (i in 1..shiftNumber+1) {
        println("\nDay $i")
        var hour = mutableListOf(countTime(inTimes[i-1], outTimes[i-1]))
        salary.add(computeDay(rate, inTimes[i-1], outTimes[i-1], dayTypes[i-1], 0))
    }

    //compute rest days
    for (i in shiftNumber+1..7){
        println("\nDay $i")
        var hour = mutableListOf(countTime(inTimes[i-1], outTimes[i-1]))
        salary.add(computeDay(rate, inTimes[i-1], outTimes[i-1], dayTypes[i-1], 1))
    }

    //total week salary
    var weekSalary = 0f
    for (i in 1..7){
        weekSalary += salary[i]
    }

    println("\nTotal Salary ${weekSalary}")

}