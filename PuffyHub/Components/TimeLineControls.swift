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
        HStack{
            Button(action: {
                switchingTimeLine = true
            }) {
                HStack{
                    Image(systemName: TLType_Image[timeLineData.timelineType]!)
                    Text(TLType_Text[timeLineData.timelineType]!)
                }
            }
            .frame(width: 120)
            .buttonBorderShape(.roundedRectangle(radius: 12.0))
            .confirmationDialog("Select Timeline", isPresented: $switchingTimeLine, titleVisibility: .visible) {
                ForEach(TLType_Text.sorted{(first, second) -> Bool in return first.value > second.value}, id: \.key) { key, value in
                    Button(action: {
                        timeLineData.timelineType = key
                        Task {
                            await loadData(timeLineData: timeLineData, appSettings: appSettings)
                        }
                    }) {
                        Text(value)
                    }
                }
            }
            Button(action: {
                Task {
                    print("Refresh")
                    await loadData(timeLineData: timeLineData, appSettings: appSettings)
                }
            }) {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonBorderShape(.roundedRectangle(radius: 12.0))
        }
    }
}

#Preview {
    TimeLineControls()
        .environmentObject(TimeLineData())
        .environmentObject(AppSettings.example)
}
