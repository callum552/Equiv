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
         torque, density, illuminance, currency,
         bloodSugar, typography, flowRate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .length: String(localized: "Length")
        case .mass: String(localized: "Weight / Mass")
        case .temperature: String(localized: "Temperature")
        case .volume: String(localized: "Volume")
        case .area: String(localized: "Area")
        case .speed: String(localized: "Speed")
        case .time: String(localized: "Time")
        case .digitalStorage: String(localized: "Digital Storage")
        case .energy: String(localized: "Energy")
        case .pressure: String(localized: "Pressure")
        case .angle: String(localized: "Angle")
        case .frequency: String(localized: "Frequency")
        case .fuelEconomy: String(localized: "Fuel Economy")
        case .power: String(localized: "Power")
        case .force: String(localized: "Force")
        case .dataTransferRate: String(localized: "Data Transfer Rate")
        case .torque: String(localized: "Torque")
        case .density: String(localized: "Density")
        case .illuminance: String(localized: "Illuminance")
        case .currency: String(localized: "Currency")
        case .bloodSugar: String(localized: "Blood Sugar")
        case .typography: String(localized: "Typography")
        case .flowRate: String(localized: "Flow Rate")
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
        case .currency: "dollarsign.circle"
        case .bloodSugar: "drop.fill"
        case .typography: "textformat.size"
        case .flowRate: "water.waves"
        }
    }

    var isCurrency: Bool { self == .currency }

    var isCustom: Bool {
        switch self {
        case .force, .dataTransferRate, .torque, .density, .illuminance,
             .bloodSugar, .typography, .flowRate:
            return true
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
        case .force, .dataTransferRate, .torque, .density, .illuminance,
             .currency, .bloodSugar, .typography, .flowRate:
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
        case .bloodSugar:
            // Base: mg/dL. 1 mmol/L = 18.0182 mg/dL
            return [
                CustomUnit(name: "Milligrams per decilitre", symbol: "mg/dL", toBaseFactor: 1.0),
                CustomUnit(name: "Millimoles per litre", symbol: "mmol/L", toBaseFactor: 18.0182),
            ]
        case .typography:
            // Base: point (pt). 1 inch = 72 pt = 96 px (CSS). 1 pica = 12 pt.
            // em/rem at 16px default = 12 pt. dp at 160dpi: 1 dp = 72/160 pt = 0.45 pt.
            return [
                CustomUnit(name: "Points", symbol: "pt", toBaseFactor: 1.0),
                CustomUnit(name: "Pixels (96 dpi)", symbol: "px", toBaseFactor: 0.75),
                CustomUnit(name: "Picas", symbol: "pc", toBaseFactor: 12.0),
                CustomUnit(name: "Em (16px base)", symbol: "em", toBaseFactor: 12.0),
                CustomUnit(name: "DP / DIP (160 dpi)", symbol: "dp", toBaseFactor: 0.45),
            ]
        case .flowRate:
            // Base: litres per second (L/s)
            return [
                CustomUnit(name: "Cubic metres per second", symbol: "m³/s", toBaseFactor: 1000.0),
                CustomUnit(name: "Litres per second", symbol: "L/s", toBaseFactor: 1.0),
                CustomUnit(name: "Litres per minute", symbol: "L/min", toBaseFactor: 1.0 / 60.0),
                CustomUnit(name: "Litres per hour", symbol: "L/hr", toBaseFactor: 1.0 / 3600.0),
                CustomUnit(name: "Millilitres per minute", symbol: "mL/min", toBaseFactor: 0.001 / 60.0),
                CustomUnit(name: "US Gallons per minute", symbol: "GPM", toBaseFactor: 3.78541 / 60.0),
                CustomUnit(name: "Cubic feet per minute", symbol: "CFM", toBaseFactor: 28.3168 / 60.0),
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
