/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The implementation details of a structure that hold the parameters algorithms use for
 estimating poses.
*/

import CoreGraphics

enum Algorithm: Int {
    case single
    case multiple
}

struct PoseBuilderConfiguration {
    /// The minimum value for valid joints in a pose.
    var jointConfidenceThreshold = 0.1

    /// The minimum value for a valid pose.
    var poseConfidenceThreshold = 0.5

    /// The minimum distance between two distinct joints of the same type.
    ///
    /// - Note: This parameter only applies to the multiple-pose algorithm.
    var matchingJointDistance = 40.0

    /// Search radius used when checking if a joint has the greatest confidence amongst its neighbors.
    ///
    /// - Note: This parameter only applies to the multiple-pose algorithm.
    var localSearchRadius = 3

    /// The maximum number of poses returned.
    ///
    /// - Note: This parameter only applies to the multiple-pose algorithm.
    var maxPoseCount = 15

    /// The number of iterations performed to refine an adjacent joint's position.
    ///
    /// - Note: This parameter only applies to the multiple-pose algorithm.
    var adjacentJointOffsetRefinementSteps = 3
    
    // MARK: - 深蹲的阈值
    /// 正面简单模式
    var frontEasyAngleThreshold: CGFloat = 55
    /// 正面中等模式
    var frontMediumAngleThreshold: CGFloat = 65
    /// 正面困难模式
    var frontHardAngleThreshold: CGFloat = 75
    
    /// 侧面简单模式
    var sideEasyAngleThreshold: CGFloat = 100
    /// 侧面中等模式
    var sideMediumAngleThreshold: CGFloat = 110
    /// 侧困难模式
    var sideHardAngleThreshold: CGFloat = 120
    
    
}
