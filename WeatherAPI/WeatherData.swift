//
//  WeatherData.swift
//  WeatherAPI
//
//  Created by 大江祥太郎 on 2021/08/01.
//


import Foundation

//Codable = Decodable & Encodable

struct WeatherData : Codable{
    let name:String
    let main:Main
    let weather:[Weather]
    
}

struct Main:Codable {
    let temp:Double
    
}

struct Weather:Codable {
    let description:String
    let id:Int
    
    
}

