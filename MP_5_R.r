# ###################
#Last names: Garcia, Meneses, Santos, Telosa
#Language: R
#Paradigm(s): Functional
# ###################

countTime <- function(inTime, outTime) {
    hours <- c()
    work <- 0
    nwork <- 0
    ot <- 0
    nsot <- 0

    if (inTime == outTime) {
        hours <- c(work, nwork, ot, nsot)
        return(hours)
    }

    while (inTime != outTime) {
        if (work < 9 && (inTime >= 601 && inTime <= 2199)) {
            work <- work + 1
        } else if (work < 9 && (inTime >= 2200 || inTime < 600)) {
            nwork <- nwork + 1
        } else if (work >= 9 && (inTime >= 601 && inTime <= 2199)) {
            work <- work + 1
            ot <- ot + 1
        } else if (work >= 9 && (inTime >= 2200 || inTime < 600)) {
            work <- work + 1
            nsot <- nsot + 1
        }
            inTime <- (inTime + 100) %% 2400
    }

    hours <- c(work, nwork, ot, nsot)
    return(hours)
}

computeDay <- function(rate, inTime, outTime, dayType, restDay) {
    salary <- rate
    salaryRate <- dayRate(dayType, restDay)
    hours <- countTime(inTime, outTime)

    if (hours[2] == 0) {
        salary <- rate * salaryRate
    } else {
        salary <- (rate / 8) * (hours[1] - 1)
        salary <- salary + (((rate / 8) + (rate / 8 * 0.1)) * hours[2])
    }

    if (hours[1] == 0){
        cat("Did Not attend Today")
        return(0)
    }

    otRate <- overTimeRate(dayType, restDay, 0)
    ot <- (rate / 8) * hours[3] * otRate
    nsotRate <- overTimeRate(dayType, restDay, 1)
    nsot <- (rate / 8) * hours[4] * nsotRate

    salary <- salary + ot + nsot

    dayTypes <- c("Normal Day", "SNWH", "Regular Holiday")
    restDays <- c("", ", RestDay")

    cat("Daily Rate:", rate, "\n")
    cat("IN Time:", inTime, "\n")
    cat("OUT Time:", outTime, "\n")
    cat("Day Type:", dayTypes[dayType], restDays[restDay + 1], "\n")

    if (hours[2] > 0) {
        cat("Hours on Night Shift:", hours[2], "\n")
    }
    cat("Hours OverTime (Night Shift OverTime):", hours[3], "(", hours[4], ")\n")
    cat("Salary of the day:", salary, "\n")
    cat("Computation:\n")

    if (dayType > 1 || restDay == 1) {
        cat("Daily Rate =", rate, "*", salaryRate, "\n")
    } else {
        cat("Daily Rate:", rate, "\n")
    }

    if (hours[2] > 0) {
        cat("Hours on NS x Hourly Rate x NSD\n")
        cat(hours[2], "*", rate, "*", salaryRate, "/ 8 + 10%\n")
    }

    if (hours[3] > 0) {
        cat("Hours OT x OT Rate\n")
        cat(hours[3], "*", rate, "*", salaryRate, "/ 8 *", otRate, "=", ot, "\n")
    }

    if (hours[4] > 0) {
        cat("Hours NS-OT x OT Rate\n")
        cat(hours[4], "*", rate, "*", salaryRate, "/ 8 *", nsotRate, "=", nsot, "\n")
    }

    return(salary)
}

dayRate <- function(i, restDay) {
    if (restDay == 0) {
        if (i == 1) {
            return(1.0)
        } else if (i == 2) {
            return(1.3)
        } else {
            return(2.0)
        }
    } else {
        if (i == 1) {
            return(1.3)
        } else if (i == 2) {
            return(1.5)
        } else {
            return(2.60)
        }
    }
}

overTimeRate <- function(dayType, restDay, nightShift) {
    if (nightShift == 0) {
        if (dayType == 1 && restDay == 0) {
            return(1.25)
        } else if (dayType == 1 && restDay == 1) {
            return(1.69)
        } else if (dayType == 2 && restDay == 0) {
            return(1.69)
        } else if (dayType == 2 && restDay == 1) {
            return(1.95)
        } else if (dayType == 3 && restDay == 0) {
            return(2.60)
        } else if (dayType == 3 && restDay == 1) {
            return(3.38)
        }
    } else {
        if (dayType == 1 && restDay == 0) {
            return(1.375)
        } else if (dayType == 1 && restDay == 1) {
            return(1.859)
        } else if (dayType == 2 && restDay == 0) {
            return(1.859)
        } else if (dayType == 2 && restDay == 1) {
            return(2.145)
        } else if (dayType == 3 && restDay == 0) {
            return(2.86)
        } else if (dayType == 3 && restDay == 1) {
            return(3.718)
        }
    }

    return(0)
}

main <- function() {
    shiftNumber <- as.integer(readline("Number of Work Days: "))

    rate <- as.numeric(readline("Daily Rate: "))
    if (rate < 500) {
        cat("You entered a low salary, setting the daily rate to 500.\n")
        rate <- 500.0
    }

    inTimes <- numeric(7)
    outTimes <- numeric(7)
    dayTypes <- integer(7)

    for (i in 1:7) {
        cat("day:", i, "\n")
        inTimes[i] <- as.integer(readline("In Time: "))
        outTimes[i] <- as.integer(readline("Time Out: "))
        dayTypes[i] <- as.integer(readline("1. Normal Day  2. Special Non-Working Day 3. Regular Holiday: "))
    }

    salary <- numeric(7)

    for (i in 1:shiftNumber) {
        cat("\nDay", i, "\n")
        salary[i] <- computeDay(rate, inTimes[i], outTimes[i], dayTypes[i], 0)
    }

    for (i in shiftNumber:7) {
        cat("\nDay", i, "\n")
        salary[i] <- computeDay(rate, inTimes[i], outTimes[i], dayTypes[i], 1)
    }

    weekSalary <- sum(salary)
    cat("\nTotal Salary:", weekSalary, "\n")
}

main()