//
//  ActionUtilities.swift
//  cap
//
//  Created by Andrew Tu on 2/8/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

// MARK: Light Action Helpers
func createSetColorAction(deviceType: DeviceType, deviceId: String, color: UIColor) -> Action {
  let colorAction = LightAction.setColor(SetColorAction(color: CodableColor(uiColor: color)))
  return Action(deviceType: deviceType, deviceId: deviceId, action: IotAction.lightAction(colorAction))
}

func createSetBrightnessAction(deviceType: DeviceType, deviceId: String, brightness: Float) -> Action {
  let brightnessAction = LightAction.setBrightness(SetBrightnessAction(brightness: brightness))
  return Action(deviceType: deviceType, deviceId: deviceId, action: IotAction.lightAction(brightnessAction))
}

func createSetLightOn(deviceType: DeviceType, deviceId: String, on: Bool) -> Action {
  let onAction = LightAction.setIsOn(SetOnAction(isOn: on))
  return Action(deviceType: deviceType, deviceId: deviceId, action: IotAction.lightAction(onAction))
}

// MARK: Lock Action Helpers
func createSetLocked(deviceType: DeviceType, deviceId: String, locked: Bool) -> Action {
  let lockAction = LockAction.setLock(SetLockAction(isLocked: locked))
  return Action(deviceType: deviceType, deviceId: deviceId, action: IotAction.lockAction(lockAction))
}
