//
//  ItemCharacter.swift
//  EfcRickMorty
//
//  Created by efulgencio on 6/10/25.
//

import SwiftUI

struct ItemCharacter: View {
    
    let item: Any // ListItem
    
    var body: some View {
        if let model = item as? ListItem {
            VStack(spacing: 5) {
                HStack{
                    Text("\(model.id)")
                        .padding(.leading, 20)
                    HStack {
                        Text("\(model.name)")
                            .padding(.horizontal, 20)
                        Spacer()
                        CachedAsyncImage(
                            url: URL(string: model.image),
                            placeholder: Image(systemName: "person.crop.circle")
                        )
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding()
                    }
                    .modifier(CustomModifierCardDetailItem())
                    .shadow(radius: 20)

                }
                .frame(maxWidth: .infinity)
                .background(Color.themeItem.body)
                .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .topRight]))
            
            }.padding(20)
         } else if let message = item as? String, message == "no encontrado" {
            // Vista especial para "no encontrado"
            Text("No se encontraron registros 🧐")
                .foregroundColor(.red)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            // Fallback si no es un modelo o el mensaje especial
            EmptyView()
        }
    }
    
    private var imagePlaceHolder: some View {
        Image(systemName:"person.crop.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
    }
    
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ItemCharacter(item: ListItem.mock())
}
