//
//  UnitCategory.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import Foundation

// MARK: - Unit Category Enum

enum UnitCategoryType: String, CaseIterable, Identifiable {
    case length, mass, temperature, volume, area, speed, time,
         digitalStorage, energy, pressure, angle, frequency,
         fuelEconomy, power, force, dataTransferRate,
         torque, density, illuminance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .length: "Length"
        case .mass: "Weight / Mass"
        case .temperature: "Temperature"
        case .volume: "Volume"
        case .area: "Area"
        case .speed: "Speed"
        case .time: "Time"
        case .digitalStorage: "Digital Storage"
        case .energy: "Energy"
        case .pressure: "Pressure"
        case .angle: "Angle"
        case .frequency: "Frequency"
        case .fuelEconomy: "Fuel Economy"
        case .power: "Power"
        case .force: "Force"
        case .dataTransferRate: "Data Transfer Rate"
        case .torque: "Torque"
        case .density: "Density"
        case .illuminance: "Illuminance"
        }
    }

    var icon: String {
        switch self {
        case .length: "ruler"
        case .mass: "scalemass"
        case .temperature: "thermometer.medium"
        case .volume: "cup.and.saucer"
        case .area: "square.dashed"
        case .speed: "gauge.with.needle"
        case .time: "clock"
        case .digitalStorage: "internaldrive"
        case .energy: "bolt"
        case .pressure: "barometer"
        case .angle: "angle"
        case .frequency: "waveform"
        case .fuelEconomy: "fuelpump"
        case .power: "powerplug"
        case .force: "arrow.up.and.down"
        case .dataTransferRate: "network"
        case .torque: "wrench.and.screwdriver"
        case .density: "cube"
        case .illuminance: "lightbulb"
        }
    }

    var isCustom: Bool {
        switch self {
        case .force, .dataTransferRate, .torque, .density, .illuminance: return true
        default: return false
        }
    }

    /// Foundation Dimension objects for categories backed by the Measurement API.
    /// Every unit is fully qualified because the return type is [Dimension] (base class).
    var dimensions: [Dimension] {
        switch self {
        case .length:
            return [UnitLength.meters, UnitLength.kilometers, UnitLength.centimeters,
                    UnitLength.millimeters, UnitLength.miles, UnitLength.yards,
                    UnitLength.feet, UnitLength.inches, UnitLength.nauticalMiles,
                    UnitLength.micrometers]
        case .mass:
            return [UnitMass.kilograms, UnitMass.grams, UnitMass.milligrams,
                    UnitMass.pounds, UnitMass.ounces, UnitMass.stones,
                    UnitMass.metricTons, UnitMass.shortTons]
        case .temperature:
            return [UnitTemperature.celsius, UnitTemperature.fahrenheit,
                    UnitTemperature.kelvin]
        case .volume:
            return [UnitVolume.liters, UnitVolume.milliliters, UnitVolume.gallons,
                    UnitVolume.quarts, UnitVolume.pints, UnitVolume.cups,
                    UnitVolume.fluidOunces, UnitVolume.tablespoons,
                    UnitVolume.teaspoons, UnitVolume.cubicMeters]
        case .area:
            return [UnitArea.squareMeters, UnitArea.squareKilometers,
                    UnitArea.squareFeet, UnitArea.squareYards, UnitArea.squareMiles,
                    UnitArea.acres, UnitArea.hectares, UnitArea.squareInches,
                    UnitArea.squareCentimeters]
        case .speed:
            return [UnitSpeed.metersPerSecond, UnitSpeed.kilometersPerHour,
                    UnitSpeed.milesPerHour, UnitSpeed.knots]
        case .time:
            return [UnitDuration.seconds, UnitDuration.minutes, UnitDuration.hours]
        case .digitalStorage:
            return [UnitInformationStorage.bytes, UnitInformationStorage.kilobytes,
                    UnitInformationStorage.megabytes, UnitInformationStorage.gigabytes,
                    UnitInformationStorage.terabytes, UnitInformationStorage.petabytes,
                    UnitInformationStorage.kibibytes, UnitInformationStorage.mebibytes,
                    UnitInformationStorage.gibibytes, UnitInformationStorage.tebibytes]
        case .energy:
            return [UnitEnergy.joules, UnitEnergy.kilojoules, UnitEnergy.calories,
                    UnitEnergy.kilocalories, UnitEnergy.kilowattHours]
        case .pressure:
            return [UnitPressure.newtonsPerMetersSquared, UnitPressure.kilopascals,
                    UnitPressure.hectopascals, UnitPressure.bars,
                    UnitPressure.millibars, UnitPressure.poundsForcePerSquareInch,
                    UnitPressure.millimetersOfMercury, UnitPressure.inchesOfMercury]
        case .angle:
            return [UnitAngle.degrees, UnitAngle.radians, UnitAngle.revolutions,
                    UnitAngle.arcMinutes, UnitAngle.arcSeconds, UnitAngle.gradians]
        case .frequency:
            return [UnitFrequency.hertz, UnitFrequency.kilohertz,
                    UnitFrequency.megahertz, UnitFrequency.gigahertz,
                    UnitFrequency.terahertz]
        case .fuelEconomy:
            return [UnitFuelEfficiency.litersPer100Kilometers,
                    UnitFuelEfficiency.milesPerGallon,
                    UnitFuelEfficiency.milesPerImperialGallon]
        case .power:
            return [UnitPower.watts, UnitPower.kilowatts, UnitPower.megawatts,
                    UnitPower.horsepower, UnitPower.milliwatts]
        case .force, .dataTransferRate, .torque, .density, .illuminance:
            return []
        }
    }

    var customUnits: [CustomUnit] {
        switch self {
        case .force:
            return [
                CustomUnit(name: "Newtons", symbol: "N", toBaseFactor: 1.0),
                CustomUnit(name: "Kilonewtons", symbol: "kN", toBaseFactor: 1000.0),
                CustomUnit(name: "Pound-force", symbol: "lbf", toBaseFactor: 4.44822),
                CustomUnit(name: "Dynes", symbol: "dyn", toBaseFactor: 0.00001),
                CustomUnit(name: "Kilogram-force", symbol: "kgf", toBaseFactor: 9.80665),
            ]
        case .dataTransferRate:
            return [
                CustomUnit(name: "Bits per second", symbol: "bps", toBaseFactor: 1.0),
                CustomUnit(name: "Kilobits per second", symbol: "Kbps", toBaseFactor: 1000.0),
                CustomUnit(name: "Megabits per second", symbol: "Mbps", toBaseFactor: 1_000_000.0),
                CustomUnit(name: "Gigabits per second", symbol: "Gbps", toBaseFactor: 1_000_000_000.0),
                CustomUnit(name: "Bytes per second", symbol: "B/s", toBaseFactor: 8.0),
                CustomUnit(name: "Kilobytes per second", symbol: "KB/s", toBaseFactor: 8000.0),
                CustomUnit(name: "Megabytes per second", symbol: "MB/s", toBaseFactor: 8_000_000.0),
            ]
        case .torque:
            return [
                CustomUnit(name: "Newton-metres", symbol: "N·m", toBaseFactor: 1.0),
                CustomUnit(name: "Foot-pounds", symbol: "ft·lbf", toBaseFactor: 1.35582),
                CustomUnit(name: "Inch-pounds", symbol: "in·lbf", toBaseFactor: 0.112985),
                CustomUnit(name: "Kilogram-force metres", symbol: "kgf·m", toBaseFactor: 9.80665),
            ]
        case .density:
            return [
                CustomUnit(name: "Kilograms per cubic metre", symbol: "kg/m³", toBaseFactor: 1.0),
                CustomUnit(name: "Grams per cubic centimetre", symbol: "g/cm³", toBaseFactor: 1000.0),
                CustomUnit(name: "Pounds per cubic foot", symbol: "lb/ft³", toBaseFactor: 16.0185),
                CustomUnit(name: "Pounds per cubic inch", symbol: "lb/in³", toBaseFactor: 27679.9),
                CustomUnit(name: "Grams per litre", symbol: "g/L", toBaseFactor: 1.0),
            ]
        case .illuminance:
            return [
                CustomUnit(name: "Lux", symbol: "lx", toBaseFactor: 1.0),
                CustomUnit(name: "Foot-candles", symbol: "fc", toBaseFactor: 10.7639),
                CustomUnit(name: "Phot", symbol: "ph", toBaseFactor: 10000.0),
                CustomUnit(name: "Nox", symbol: "nx", toBaseFactor: 0.001),
            ]
        default:
            return []
        }
    }
}

// MARK: - Custom Unit (for categories without Foundation support)

struct CustomUnit: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    let toBaseFactor: Double
}

// MARK: - Dimension Display Name

extension Dimension {
    var displayName: String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        formatter.unitOptions = .providedUnit
        let measurement = Measurement(value: 0, unit: self)
        let formatted = formatter.string(from: measurement)
        // The formatter returns something like "0 meters" — strip the leading number
        let name = formatted.replacingOccurrences(
            of: "^[\\d.,\\s-]+",
            with: "",
            options: .regularExpression
        )
        return name.trimmingCharacters(in: .whitespaces).capitalized
    }
}
