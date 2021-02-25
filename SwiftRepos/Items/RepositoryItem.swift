//
//  RepositoryItem.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import SwiftUI

struct RepositoryItem: View {
    @ObservedObject var repository: Repository
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(repository.name!)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(repository.owner!)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)))
                        Text(Int(repository.stargazerCount).withCommas())
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.triangle.branch")
                        Text(Int(repository.stargazerCount).withCommas())
                    }
                }
                .font(.footnote)
            }
            Divider()
        }
        .padding(.vertical, 8)
    }
}

struct RepositoryItem_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryItem(repository: Repository.dummyData)
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
