import SwiftUI

struct OpenAIResponseView: View {
    let response: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Recognized Items")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Text(response)
                    .font(.body)
                    .padding()
            }
        }
        .navigationBarTitle("Results", displayMode: .inline)
    }
}
