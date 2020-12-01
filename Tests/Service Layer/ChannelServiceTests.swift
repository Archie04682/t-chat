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
        sut.add(withName: "Test Name") { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            
            XCTAssertEqual(self.dataProvider.addCallsCount, 1)
        }
    }
    
    func testShouldReturnError_On_FailSaving() {
        sut.add(withName: "failedName") { error in
            XCTAssertEqual(self.dataProvider.addCallsCount, 1)
            XCTAssertNotNil(error)
        }
    }
    
    func testShouldDeleteChannel_And_UpdatesData() {
        let delegate = ChannelServiceDelegateMock()
        
        sut.delegate = delegate
        
        sut.delete(withUID: "testUID") { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            
            XCTAssertEqual(self.dataProvider.deleteCallsCount, 1)
            XCTAssertEqual(delegate.delegateCallsCount, 1)
        }
    }
}
