//
//  CvHelper.hpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifndef CvHelper_hpp
#define CvHelper_hpp

#include <array>
#include <string>

using Box = std::array<int, 4>;

double EuclideanDistanceCenter(const Box boxA, const Box boxB);

Box ConvertBoxRep(const Box box);

double CalculateIou(const Box boxA, const Box boxB);

std::string BoxToString(const Box box);

#endif /* CvHelper_hpp */
