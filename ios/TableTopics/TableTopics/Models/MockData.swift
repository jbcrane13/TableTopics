// MockData.swift
// Sample leads for development and demos

import B2BCore
import Foundation

struct MockData {
    static let sampleLeads: [Lead] = {
        // Hot lead - ABC Construction
        let abcAddress = Address(street: "1234 Commerce Blvd", city: "Austin", state: "TX", zip: "78701")
        let abcCompany = Company(
            name: "ABC Construction LLC",
            address: abcAddress,
            phone: "512-555-1234",
            email: "info@abcconstruction.com",
            licenseStatus: .active,
            yearsInBusiness: 15,
            completedProjects: 127,
            totalProjects: 130
        )
        let abcProject = Project(
            permitNumber: "BP-2024-45892",
            permitType: .renovation,
            description: "Hotel lobby and restaurant renovation - 3 story",
            address: abcAddress,
            estimatedValue: 850_000,
            status: .approved
        )
        var abcLead = Lead(company: abcCompany, project: abcProject)
        abcLead.decisionMakers = [
            DecisionMaker(name: "John Martinez", title: "Owner", email: "jmartinez@abcconstruction.com", phone: "512-555-1235", confidence: 0.95, quality: .verified)
        ]
        abcLead.updateScore(LeadScore.calculate(for: abcLead))
        
        // Warm lead - XYZ Builders
        let xyzAddress = Address(street: "5678 Industrial Pkwy", city: "Houston", state: "TX", zip: "77001")
        let xyzCompany = Company(
            name: "XYZ Builders Inc",
            address: xyzAddress,
            phone: "713-555-2345",
            licenseStatus: .active,
            yearsInBusiness: 8,
            completedProjects: 45,
            totalProjects: 52
        )
        let xyzProject = Project(
            permitNumber: "BP-2024-38291",
            permitType: .newConstruction,
            description: "New restaurant construction",
            address: xyzAddress,
            estimatedValue: 1_200_000,
            status: .inProgress
        )
        var xyzLead = Lead(company: xyzCompany, project: xyzProject)
        xyzLead.decisionMakers = [
            DecisionMaker(name: "Sarah Chen", title: "Project Manager", email: "schen@xyzbuilders.com", confidence: 0.7, quality: .inferred)
        ]
        xyzLead.updateScore(LeadScore.calculate(for: xyzLead))
        
        // Cool lead - Delta Contractors
        let deltaAddress = Address(street: "9012 Oak Lane", city: "Dallas", state: "TX", zip: "75201")
        let deltaCompany = Company(
            name: "Delta Contractors",
            address: deltaAddress,
            phone: "214-555-3456",
            licenseStatus: .active,
            yearsInBusiness: 3,
            completedProjects: 18,
            totalProjects: 22
        )
        let deltaProject = Project(
            permitType: .electrical,
            description: "Electrical upgrade for commercial space",
            address: deltaAddress,
            estimatedValue: 75_000,
            status: .filed
        )
        var deltaLead = Lead(company: deltaCompany, project: deltaProject)
        deltaLead.decisionMakers = [
            DecisionMaker(name: "Mike Wilson", title: "Owner", confidence: 0.5, quality: .partial)
        ]
        deltaLead.updateScore(LeadScore.calculate(for: deltaLead))
        
        // Cold lead - Omega Building
        let omegaAddress = Address(street: "3456 Pine St", city: "San Antonio", state: "TX", zip: "78201")
        let omegaCompany = Company(
            name: "Omega Building Services",
            address: omegaAddress,
            licenseStatus: .unknown
        )
        let omegaProject = Project(
            permitType: .demolition,
            description: "Small demolition project",
            address: omegaAddress,
            estimatedValue: 25_000,
            status: .filed
        )
        var omegaLead = Lead(company: omegaCompany, project: omegaProject)
        omegaLead.updateScore(LeadScore.calculate(for: omegaLead))
        
        // Another hot lead - Prime Hotels
        let primeAddress = Address(street: "7890 Resort Dr", city: "Galveston", state: "TX", zip: "77550")
        let primeCompany = Company(
            name: "Prime Hospitality Builders",
            address: primeAddress,
            phone: "409-555-4567",
            email: "contact@primehb.com",
            website: URL(string: "https://primehb.com"),
            licenseStatus: .active,
            yearsInBusiness: 22,
            completedProjects: 89,
            totalProjects: 92
        )
        let primeProject = Project(
            permitNumber: "BP-2024-51234",
            permitType: .renovation,
            description: "Full hotel renovation - 150 rooms",
            address: primeAddress,
            estimatedValue: 2_500_000,
            status: .approved
        )
        var primeLead = Lead(company: primeCompany, project: primeProject)
        primeLead.decisionMakers = [
            DecisionMaker(name: "Robert Thompson", title: "CEO", email: "rthompson@primehb.com", phone: "409-555-4568", confidence: 0.98, quality: .verified),
            DecisionMaker(name: "Lisa Park", title: "VP Operations", email: "lpark@primehb.com", confidence: 0.85, quality: .verified)
        ]
        primeLead.updateScore(LeadScore.calculate(for: primeLead))
        
        return [abcLead, xyzLead, deltaLead, omegaLead, primeLead]
    }()
    
    static let hotLeads: [Lead] = sampleLeads.filter { $0.score?.tier == .hot }
    static let warmLeads: [Lead] = sampleLeads.filter { $0.score?.tier == .warm }
    static let coolLeads: [Lead] = sampleLeads.filter { $0.score?.tier == .cool }
    static let coldLeads: [Lead] = sampleLeads.filter { $0.score?.tier == .cold }
}
