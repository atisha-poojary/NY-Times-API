//
//  Result.swift
//  NY_Times
//
//  Created by Atisha Poojary on 31/10/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import Foundation

enum Error<T, E> {
    case Success(T)
    case Failure(E)
}
