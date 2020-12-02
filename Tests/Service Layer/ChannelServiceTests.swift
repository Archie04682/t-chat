//
//  ChannelServiceTests.swift
//  Tests
//
//  Created by Артур Гнедой on 30.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

import XCTest
@testable import t_chat

class ChannelServiceTests: XCTestCase {
    
    var dataProvider: ChannelDataProviderMock!
    var channelRepository: ChannelRepositoryMock!
    var sut: CombinedChannelService!
    
    override func setUp() {
        super.setUp()
        dataProvider = ChannelDataProviderMock()
        channelRepository = ChannelRepositoryMock()
        sut = CombinedChannelService(channelDataProvider: dataProvider, channelRepository: channelRepository)
    }
    
    func testShouldAddNewChannel() {
        let rightParameter = "Test Name"
        sut.add(withName: "Test Name") { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            
            XCTAssertEqual(rightParameter, self.dataProvider.addLastCallParameter)
            XCTAssertEqual(1, self.dataProvider.addCallsCount)
        }
    }
    
    func testShouldReturnError_On_FailSaving() {
        let wrongParameter = "failedName"
        sut.add(withName: wrongParameter) { error in
            XCTAssertEqual(wrongParameter, self.dataProvider.addLastCallParameter)
            XCTAssertEqual(1, self.dataProvider.addCallsCount)
            XCTAssertNotNil(error)
        }
    }
    
    func testShouldDeleteChannel_And_UpdatesData() {
        let delegate = ChannelServiceDelegateMock()
        
        sut.delegate = delegate
        
        let uid = "testUID"
        
        sut.delete(withUID: uid) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            
            XCTAssertEqual(uid, self.dataProvider.lastDeleteCallParameter)
            XCTAssertEqual(1, self.dataProvider.deleteCallsCount)
            XCTAssertEqual(1, delegate.delegateCallsCount)
        }
    }
}
