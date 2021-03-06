//
//  ViewController.swift
//  ActivityGoal
//
//  Created by Andreas Schulz on 06.07.16.
//  Copyright © 2016 Andreas Schulz. All rights reserved.
//

import UIKit
import HealthKit


class ViewController: UIViewController {
    @IBOutlet weak var labelTotalActivities: UILabel!
    @IBOutlet weak var labelReachedGoalActivities: UILabel!
    @IBAction func reloadPressed(_ sender: AnyObject) {
        updateLabels()
    }
    let healthStore = HKHealthStore()
    let activityType = HKObjectType.activitySummaryType()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }

    func updateLabels() {
        let readTypes: Set<HKObjectType> = Set([activityType])
        self.healthStore.requestAuthorization(toShare: nil, read: readTypes) {
            (success: Bool, error: Error?) -> Void in
            if success {
                self.queryHealth()
            }
        }
    }

    func queryHealth() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let startDate = Date.distantPast
        let endDate = Date()
        let units: Set<Calendar.Component> = [.day, .month, .year, .era]
        var startDateComponents = calendar.dateComponents(units, from: startDate)
        startDateComponents.calendar = calendar
        var endDateComponents = calendar.dateComponents(units, from: endDate)
        endDateComponents.calendar = calendar

        let summariesWithinRange = HKQuery.predicate(
            forActivitySummariesBetweenStart: startDateComponents,
            end: endDateComponents
        )

        let query = HKActivitySummaryQuery(predicate: summariesWithinRange) {(
            query: HKActivitySummaryQuery,
            summaries: [HKActivitySummary]?,
            error: Error?) in
            var activityCount = 0
            var activityGoalAchievedCount = 0
            if let summaries = summaries {
                activityCount = summaries.count
                for summary in summaries {
                    let comparison = summary.activeEnergyBurned.compare(
                        summary.activeEnergyBurnedGoal
                    )
                    if comparison == ComparisonResult.orderedDescending ||
                        comparison == ComparisonResult.orderedSame {
                        activityGoalAchievedCount += 1
                    }
                }
                DispatchQueue.main.sync {
                    self.labelTotalActivities.text = "Total: \(activityCount)"
                    self.labelReachedGoalActivities.text =
                        "Reached goal: \(activityGoalAchievedCount)"
                }
            }
        }
        self.healthStore.execute(query)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

