//
//  ErrorPageView.swift
//  SwiftRepos
//
//  Created by Tochi on 27/02/2021.
//

import SwiftUI

struct ErrorPageView: View {
    let errorMessage: String
    var message: String{
        if errorMessage.contains("401"){
            return "Bad credentials. Please refreash your token"
        }else{
            return errorMessage
        }
    }
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.icloud.fill")
                .font(.system(size: 42, weight: .bold))
            Text(message)
                .font(.callout)
        }
    }
}

struct ErrorPageView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorPageView(errorMessage: "Failed to fetch data from server")
    }
}
