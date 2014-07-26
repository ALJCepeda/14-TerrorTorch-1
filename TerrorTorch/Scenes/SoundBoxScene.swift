//
//  SoundBoxScene.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/3/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import SpriteKit
import AVFoundation
import CoreMedia

enum SpriteAttribute:String{
    case Name = "name"
    case SoundName = "soundname"
    case SoundPath = "soundpath"
    case Rotations = "rotations" //This needs to be changed to "Animation" with a value that accepts a closure
    case Duration = "duration"
}

class SoundBoxScene: SKScene {
    
    //Information on actions expected by a SKNode
    var actionAttributes:[[String:AnyObject]] = [];
    
    override func didMoveToView(view: SKView!) {
        self.createSceneContents();
        
        //Initialize gesture recognizers
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"));
        self.view.addGestureRecognizer(singleTapRecognizer);
    }
    
    /**
    *  Initial scene configurations
    */
    func configureScene(){
        self.backgroundColor = UIColor.blackColor();
        self.scaleMode = SKSceneScaleMode.AspectFit;
    }
    
    /**
    *   Creates nodes to be used in scene.
    *   Everything is hard coded at the moment, this needs to change to something better.
    */
    func createSceneContents(){
        //Create Scene sprites
        let dollHead = createSprite("dollhead", imageName: "dollhead", size: CGSizeMake(200, 200));
        let dollHeadAttributes = createSpriteActionAttributes("dollhead", soundName: "young-girl-scream", rotations: 6, duration: 3.0);
        
        let knife = createSprite("knife", imageName: "knife", size: CGSizeMake(200,200));
        let knifeAttributes = createSpriteActionAttributes("knife", soundName: "knife-stab-splatter", rotations: 0.0, duration: 0.0);
        
        let pitchFork = createSprite("pitchfork", imageName: "pitchfork", size: CGSizeMake(200, 200));
        let pitchForkAttributes = createSpriteActionAttributes("pitchfork", soundName: "devil-laugh", rotations: 0.0, duration: 0.0);
        
        let anubis = createSprite("anubis", imageName: "anubis", size: CGSizeMake(200, 200));
        let anubisAttributes = createSpriteActionAttributes("anubis", soundName: "ghost-egyptian-phantom", rotations: 6, duration: 3.0);
        
        //Add sprite to scene
        self.addChild(dollHead);
        self.addChild(knife);
        self.addChild(pitchFork);
        self.addChild(anubis);
        
        //Store attribute information
        actionAttributes.append(dollHeadAttributes);
        actionAttributes.append(knifeAttributes);
        actionAttributes.append(pitchForkAttributes);
        actionAttributes.append(anubisAttributes);
        
        //Position nodes
        positionNode("dollhead", point: CGPointMake(0, 0), duration: 0.0);
        positionNode("knife", point: CGPointMake(0,200), duration: 0.0);
        positionNode("pitchfork", point: CGPointMake(200, 0), duration: 0.0);
        positionNode("anubis", point: CGPointMake(200,200), duration: 0.0);
    }
    
    /**
    *  Create sprite for scene
    *
    *  @param name:String      Name of the sprite, needs to be unique
    *  @param imageName:String Name of image to use for sprite
    *  @param size:CGSize      Size of the sprite
    *
    *  @return Sprite object
    */
    func createSprite(name:String, imageName:String, size:CGSize) -> SKSpriteNode{
        var sprite = SKSpriteNode(texture: SKTexture(imageNamed: imageName), color: UIColor.whiteColor(), size: size);
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        sprite.name = name;
    
        return sprite;
    }
    
    /**
    *  Positions sprite at node
    *
    *  @param name:String       Name of sprite
    *  @param point:CGPoint     Final position of sprite
    *  @param duration:Double   Animates to final position over duration. 0 will not animate.
    */
    
    func positionNode(name:String, point:CGPoint, duration:Double){
        
        if let node = self.childNodeWithName(name) as? SKSpriteNode{
            node.anchorPoint = CGPointMake(0, 0);
            let action = SKAction.moveTo(point, duration: duration);
            node.runAction(action);
            node.anchorPoint = CGPointMake(0.5, 0.5);
        } else {
            println("Could not find sprite with the name \(name)");
        }
    }
    
    /**
    *  Attributes to be used when generating action for Sprites
    *
    *  @param spriteName:String Name of the sprite, needs to be unique
    *  @param soundName:String  Name of the sound played during animation
    *  @param rotations:Int     Number of times sprite rotates during animation
    *  @param duration:Double   Duration of animation
    *
    *  @return A dictionary storing key value pairs
    */
    func createSpriteActionAttributes(spriteName:String, soundName:String, rotations:Double, duration:Double) -> [String:AnyObject]{
        var result = [String:AnyObject]();
        let path = NSBundle.mainBundle().pathForResource(soundName, ofType: SOUNDFORMAT);

        result.updateValue(spriteName, forKey: SpriteAttribute.Name.toRaw());
        result.updateValue(soundName, forKey: SpriteAttribute.SoundName.toRaw());
        result.updateValue(path, forKey: SpriteAttribute.SoundPath.toRaw());
        result.updateValue(rotations, forKey: SpriteAttribute.Rotations.toRaw());
        result.updateValue(duration, forKey: SpriteAttribute.Duration.toRaw())
        
        return result;
    }
    
    /**
    *  Evaluates any node that's present in scene based on its type and returns a default set of actions for that type based on stored attributes
    *
    *  @param node:SKNode Node to evalute, must have information available in childrenAttributes
    *
    *  @return Default actions for node. Will be node if no attributes have been defined
    */
    func evaluateNode(node:SKNode) -> [SKAction]?{
        //Get attribute information for node
        if let attributes = getAttributesForNode(node){
            
            //Attempt to cast as Sprite
            if let sprite = node as? SKSpriteNode{
                //Cast sprite attributes
                let soundFilename = (attributes[SpriteAttribute.SoundName.toRaw()]! as String) + SOUNDFORMAT;
                let rotations = (attributes[SpriteAttribute.Rotations.toRaw()]! as Double);
                let duration = (attributes[SpriteAttribute.Duration.toRaw()]! as Double);
                
                //Create sprite actions
                let soundAction = SKAction.playSoundFileNamed(soundFilename, waitForCompletion: false);
                let rotationAction = SKAction.rotateByAngle(CGFloat(rotations*M_PI), duration: NSTimeInterval.abs(duration));
                
                return [soundAction, rotationAction];
            }
            
        } else {
            println("Unable to find attribute information for node: (\(node.name))");
            //println(node);
            return nil;
        }
        return nil;
    }
    
    /**
    *  Retrieves stored attribute information for a given node using the node's name.
    *
    *  @param node:SKNode Must have a unique name that is stored within the attributes dictionary
    *
    *  @return Attribute information belonging to node.
    */
    func getAttributesForNode(node:SKNode) -> [String:AnyObject]?{
        if let nodeName = node.name{
            let attributes = $.find(actionAttributes, iterator: {
                if let attributeName = ($0 as [String:AnyObject])["name"]! as? String{
                    return attributeName == nodeName;
                }
                return false;
            })
            
            if let result = attributes as? [String:AnyObject]{
                return result;
            } else {
                println("Couldn't find a action attributes for node named \(nodeName)");
                return nil;
            }
        } else {
            println("Node must have a name in order to find action attributes");
            return nil;
        }
    }
    
    func performActions(actions:[SKAction], onNode node:SKNode){
        for action in actions{
            node.runAction(action);
        }
    }
    
    /**
    *  Handle user tap gestures
    */
    
    func handleSingleTap(recognizer:UITapGestureRecognizer){
        if(recognizer.state == UIGestureRecognizerState.Ended){
            //Get location in scene and convert point, then get node
            let location = self.convertPointFromView(recognizer.locationInView(recognizer.view));
            if let node = self.nodeAtPoint(location){
                //Retrieve actions for that node
                if let actions = evaluateNode(node){
                    self.performActions(actions, onNode: node);
                }else{
                    println("Could not evaluate node: (\(node.name))");
                }
            }
        }
    }
}
