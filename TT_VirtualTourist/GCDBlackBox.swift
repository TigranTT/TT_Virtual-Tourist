//
//  GCDBlackBox.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 9/30/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
