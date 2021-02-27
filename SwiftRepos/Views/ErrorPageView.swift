//
//  ErrorPageView.swift
//  SwiftRepos
//
//  Created by Tochi on 27/02/2021.
//

import SwiftUI

struct ErrorPageView: View {
    let errorMessage: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.icloud.fill")
                .font(.system(size: 42, weight: .bold))
            Text(errorMessage)
                .font(.callout)
        }
    }
}

struct ErrorPageView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorPageView(errorMessage: "Failed to fetch data from server")
    }
}
