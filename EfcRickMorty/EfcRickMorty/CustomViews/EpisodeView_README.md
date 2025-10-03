import SwiftUI

struct EpisodeView: View {
    let episodes: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(episodes, id: \.self) { url in
                EpisodeRow(url: url)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.themeCardDetail.body)
        .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .topRight]))
    }
}

private struct EpisodeRow: View {
    let url: String

    var body: some View {
        HStack(spacing: 12) {
            Text(url)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.leading, 20)
            Spacer()
            if let link = URL(string: url) {
                Link(destination: link) {
                    Image(systemName: "arrow.up.right.square")
                        .imageScale(.medium)
                        .foregroundStyle(.white)
                }
                .padding(.trailing, 16)
            }
        }
        .modifier(CustomModifierCardDetailItem(colorBack: Color.themeCardDetail.header, heightContent: CGFloat(60)))
    }
}
