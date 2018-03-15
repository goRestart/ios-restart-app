//
//  BumpUpTimerBarView.swift
//  LetGo
//
//  Created by Dídac on 15/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift


class BumpUpTimerBarView: UIView {

    private var maxTime: TimeInterval = 0
    private var timer: Timer = Timer()

    private let titleLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let progressBar: UIProgressView = UIProgressView(progressViewStyle: .default)


    let timeIntervalLeft = Variable<TimeInterval>(0)
    let timeLabelText = Variable<String?>(nil)
    let disposeBag = DisposeBag()

    
    // - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupRx()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func updateWithTimeLeft(timeInterval: TimeInterval, maxTime: TimeInterval) {
        self.maxTime = maxTime
        timeIntervalLeft.value = timeInterval

    }

    func resetCountdown() {
//        timeIntervalLeft.value = maxCountdown
        startCountdown()
    }

    func stopCountdown() {
        timer.invalidate()
    }

    
    private func startCountdown() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: BumpUpBanner.timerUpdateInterval, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private dynamic func updateTimer() {
        timeIntervalLeft.value = timeIntervalLeft.value-BumpUpBanner.timerUpdateInterval
    }

    private func setupUI() {

    }

    private func setupRx() {

    }

    private func setupConstraints() {

    }

    private func setAccessibilityIds() {

    }
}
