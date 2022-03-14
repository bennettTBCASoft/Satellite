//
//  Satellite.swift
//  APIPractice
//
//  Created by TBCASoft-Bennett on 2022/3/14.
//

import Foundation

struct Satellite: Decodable {
    let description: String
    let copyright: String
    let title: String
    let url: URL
    let date: String
}
