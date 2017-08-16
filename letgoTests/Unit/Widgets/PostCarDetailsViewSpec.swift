//
//  PostCarDetailsViewSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 16/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class PostCarDetailsViewSpec: QuickSpec {
    override func spec() {
        var sut: PostCarDetailsView!
        
        beforeEach {
            sut = PostCarDetailsView(shouldShowSummaryAfter: true, initialValues: [])
        }
        describe("init view") {
            context("shouldShowSummaryAfter = true") {
                beforeEach {
                    sut = PostCarDetailsView(shouldShowSummaryAfter: true, initialValues: [])
                }
                it("previous state is selectDetail as default value") {
                     expect(sut.previousState) == PostCarDetailState.selectDetail
                }
                it("state is select detail value make") {
                    expect(sut.state) == PostCarDetailState.selectDetailValue(forDetail: CarDetailType.make)
                }
            }
            context("shouldShowSummaryAfter = false") {
                beforeEach {
                    sut = PostCarDetailsView(shouldShowSummaryAfter: false, initialValues: [])
                }
                it("previous state is nil") {
                    expect(sut.previousState).to(beNil())
                }
                it("state is select detail") {
                    expect(sut.state as PostCarDetailState)   == PostCarDetailState.selectDetail
                }
            }
        }
        describe("change state") {
            context("from summary to detail value") {
                beforeEach {
                    sut = PostCarDetailsView(shouldShowSummaryAfter: false, initialValues: [])
                    sut.state = .selectDetailValue(forDetail: .make)
                }
                it("previous state is summary") {
                    expect(sut.previousState) == PostCarDetailState.selectDetail
                }
                it("state is select detail value make") {
                    expect(sut.state) == PostCarDetailState.selectDetailValue(forDetail: CarDetailType.make)
                }
            }
            context("from detail value to summary") {
                beforeEach {
                    sut = PostCarDetailsView(shouldShowSummaryAfter: false, initialValues: [])
                    sut.state = .selectDetail
                }
                it("previous state is summary") {
                    expect(sut.previousState) == PostCarDetailState.selectDetail
                }
                it("is select detail value make") {
                    expect(sut.state) == PostCarDetailState.selectDetail
                }
            }
        }
    }
}

