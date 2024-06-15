//
//  TimeLineControls.swift
//  PuffyHub Watch App
//
//  Created by Alikia2x on 2024/6/8.
//

import SwiftUI

struct TimeLineControls: View {
    @EnvironmentObject var timeLineData: TimeLineData
    @EnvironmentObject var appSettings: AppSettings
    @State private var switchingTimeLine: Bool = false
    var body: some View {
        HStack (spacing: 3.0){
            Button(action: {
                switchingTimeLine = true
            }) {
                HStack (spacing: 0){
                    Image(systemName: TLType_Image[timeLineData.timelineType]!)
                    Text(LocalizedStringKey(TLType_Text[timeLineData.timelineType]!))
                }
            }
            .frame(width: 92)
            .buttonBorderShape(.roundedRectangle(radius: 6.0))
            .confirmationDialog("Select Timeline", isPresented: $switchingTimeLine, titleVisibility: .visible) {
                ForEach(TLType_Text.sorted{(first, second) -> Bool in return first.value > second.value}, id: \.key) { key, value in
                    Button(action: {
                        timeLineData.timelineType = key
                        Task {
                            await loadData(timeLineData: timeLineData, appSettings: appSettings)
                        }
                    }) {
                        Text(LocalizedStringKey(value))
                    }
                }
            }
            NavigationLink(destination: PostView(), label: {
                Image(systemName: "paperplane")
            })
            .buttonBorderShape(.roundedRectangle(radius: 6.0))
            Button(action: {
                Task {
                    await loadData(timeLineData: timeLineData, appSettings: appSettings)
                }
            }) {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonBorderShape(.roundedRectangle(radius: 6.0))
        }
    }
}

#Preview {
    NavigationStack {
        TimeLineControls()
            .environmentObject(TimeLineData())
            .environmentObject(AppSettings.example)
    }
}
