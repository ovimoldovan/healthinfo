//
//  Post.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 21/03/2020.
//  Copyright © 2020 Ovidiu Moldovan. All rights reserved.
//

import SwiftUI

struct Post: View {
    @State var name = ""
    var body: some View {
        Form{
        TextField("Name",text: $name)
        }
        .navigationBarTitle("Post")
    }
}

struct Post_Previews: PreviewProvider {
    static var previews: some View {
        Post()
    }
}
