//
//  JSONLoader.swift
//  AttendanceTracker
//
//  Created by Nazerke Bagdatkyzy on 05.12.2025.
//
import Foundation

struct SchoolData: Codable {
    let city: String
    let regions: [RegionData]
}

struct RegionData: Codable {
    let name: String
    let schools: [SchoolInfo]
}

struct SchoolInfo: Codable {
    let id: String
    let name: String
}

// Load main JSON
var cachedData: [SchoolData] = loadJSON()

func loadJSON() -> [SchoolData] {
    if let url = Bundle.main.url(forResource: "schools", withExtension: "json"),
       let data = try? Data(contentsOf: url),
       let decoded = try? JSONDecoder().decode([SchoolData].self, from: data) {
        return decoded
    }
    return []
}

// For pickers
func loadCities() -> [String] {
    cachedData.map { $0.city }
}

func loadRegions(for city: String) -> [String] {
    cachedData.first(where: { $0.city == city })?.regions.map { $0.name } ?? []
}

func loadSchools(for city: String, region: String) -> [String] {
    cachedData
        .first(where: { $0.city == city })?
        .regions.first(where: { $0.name == region })?
        .schools.map { $0.id } ?? []
}

func schoolName(for id: String) -> String {
    for city in cachedData {
        for region in city.regions {
            if let school = region.schools.first(where: { $0.id == id }) {
                return school.name
            }
        }
    }
    return id
}
