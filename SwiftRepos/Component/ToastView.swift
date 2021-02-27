//
//  ToastView.swift
//  SwiftRepos
//
//  Created by Tochi on 27/02/2021.
//

import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var show: Bool
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(2)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 48)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                show = false
            }
        }
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(message: "Can't update data, please check network", show: .constant(true))
    }
}
