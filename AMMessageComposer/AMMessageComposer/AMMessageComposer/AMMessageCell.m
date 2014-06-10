//
//  AMMessageCell.m
//  AWSearchBar
//
//  Created by Mohan Rao on 27/01/14.
//  Copyright (c) 2014 Mohan Rao. All rights reserved.
//

#import "AMMessageCell.h"
#import "UIImage+Stretchable.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+AutoLayout.h"

#define THUMBNAIL_IMAGE_AT_TIME_INTERVEL 5.0

#define kUserResendInfoLabelVerticalInset       2.0f
#define kUserResendInfoLabelSizeWidth           80.0f
#define kUserResendInfoLabelSizeHeight          14.0f

#define kMessageDeliveryStatusLabelHorizontalInset  6.0f
#define kMessageDeliveryStatusLabelVerticalInset    4.0f
#define kMessageDeliveryStatusLabelSizeWidth        50.0f
#define kMessageDeliveryStatusLabelSizeHeight       14.0f

#define kUserAvatarBgImgViewHorizontalInset   10.0f
#define kUserAvatarBgImgViewVerticalInset     2.0f
#define kUserAvatarBgImgSizeWidth             38.0f
#define kUserAvatarBgImgSizeHeight            38.0f

#define kUserNameViewVerticalInset              4.0f
#define kUserNameViewSizeHeight                 14.0f
#define kUserNameViewHoriWidthMargin            5.0f

#define kMessageTimeLabelHorizontalInset    10.0
#define kMessageTimeLabelVerticalInset      2.0
#define kMessageTimeLabelSizeWidth          100.0
#define kMessageTimeLabelSizeHeight         14.0

#define kMessageBgImgViewHorizontalMargin    5.0f
#define kMessageBgImgViewVerticalOffset      3.0f

#define kMessageLabelHorizontalOffset        7.0f
#define kMessageLabelVerticalOffset          4.0f

#define kMultimediaMessageHorizontalInset   6.0f
#define kMultimediaMessageVerticalInset     6.0f

@interface AMMessageCell()

@property (nonatomic, strong) UIImageView *messageBgView;
@property (nonatomic, strong) UIImageView *messageImageView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) UIImage *videoThumbImage;
@property (nonatomic, strong) UIImageView *videoThumbImageView;
@property (nonatomic, assign) BOOL didSetUpSentConstraints;
@property (nonatomic, assign) BOOL didSetUpReceivedConstraints;

@end

@implementation AMMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UI utility
-(void) setUI
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView.layer setOpaque:YES];
    
    //    user status - user imageBackgroud view
    UIView *userImgBgView = [UIView newAutoLayoutView];
    userImgBgView.backgroundColor = [UIColor redColor];
    userImgBgView.layer.cornerRadius = kUserAvatarBgImgSizeHeight/2.0;
    [self.contentView addSubview:userImgBgView];
    self.userAvatarBgView = userImgBgView;
    [self.userAvatarBgView setHidden:YES];
    
    //    user
    UIImageView *userImgView = [UIImageView newAutoLayoutView];
    userImgView.layer.cornerRadius = (kUserAvatarBgImgSizeHeight-2)/2.0;
//    userImgView.layer.borderWidth = 2.0;
//    userImgView.layer.borderColor = [UIColor whiteColor].CGColor;
    [userImgView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:userImgView];
    self.userAvatarImgView = userImgView;
    
    //    user name
    UILabel *userNameLbl = [UILabel newAutoLayoutView];
    userNameLbl.backgroundColor = [UIColor clearColor];
    userNameLbl.textColor = [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1.0];
    [userNameLbl setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
    [userNameLbl setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:userNameLbl];
    self.userNameLbl = userNameLbl;
    
    //message delivery status
    UILabel *messageDeliveryStatusLabel = [UILabel newAutoLayoutView];
    messageDeliveryStatusLabel.backgroundColor = [UIColor clearColor];
    messageDeliveryStatusLabel.textColor = [UIColor lightGrayColor];//[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    [messageDeliveryStatusLabel setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
    [messageDeliveryStatusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:messageDeliveryStatusLabel];
    self.messageDeliveryStatusLabel = messageDeliveryStatusLabel;
    
    //    message back ground
    UIImageView *messageBgView = [UIImageView newAutoLayoutView];
    [messageBgView setUserInteractionEnabled:YES];
    [self.contentView addSubview:messageBgView];
    [self.messageBgView setBackgroundColor:[UIColor redColor]];
    self.messageBgView = messageBgView;
    
    //    message sent/received time
    UILabel *messageTimeLabel = [UILabel newAutoLayoutView];
    messageTimeLabel.backgroundColor = [UIColor clearColor];
    messageTimeLabel.textColor = [UIColor lightGrayColor];
    [messageTimeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0]];
    [self.contentView addSubview:messageTimeLabel];
    self.messageSentTimeLbl = messageTimeLabel;
    
    //    text message
    UILabel *messageLbl = [UILabel newAutoLayoutView];
    messageLbl.backgroundColor = [UIColor clearColor];
    [messageLbl setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
    messageLbl.numberOfLines = 0;
    messageLbl.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:messageLbl];
    self.messageLbl = messageLbl;
    
    //    image message
    UIImageView *messageImgView = [UIImageView newAutoLayoutView];
    [self.messageBgView addSubview:messageImgView];
    self.messageImageView = messageImgView;
    
    //    video message
    MPMoviePlayerController *moviePlayerController = [[MPMoviePlayerController alloc] init];
    [moviePlayerController setControlStyle:MPMovieControlStyleEmbedded];
    [moviePlayerController setScalingMode:MPMovieScalingModeAspectFit];
    [moviePlayerController setMovieSourceType:MPMovieSourceTypeFile];
    [moviePlayerController prepareToPlay];
    [self.messageBgView addSubview:moviePlayerController.view];
    self.moviePlayerController = moviePlayerController;
    
    UIImageView *videoThumbnailImgView = [UIImageView newAutoLayoutView];
    videoThumbnailImgView.backgroundColor = [UIColor clearColor];
    [videoThumbnailImgView setUserInteractionEnabled:YES];
    [self.messageBgView addSubview:videoThumbnailImgView];
    self.videoThumbImageView = videoThumbnailImgView;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(playOrPauseVideo)];
    [self.videoThumbImageView addGestureRecognizer:tapGestureRecognizer];
}

-(void) updateConstraints
{
    [super updateConstraints];
    
    if (self.isSentMessage)
    {
        if (self.didSetUpSentConstraints) {
            return;
        }
        
        // Message Delivery status
        [self.messageDeliveryStatusLabel autoPinEdgeToSuperviewEdge:ALEdgeTop
                                                          withInset:kMessageDeliveryStatusLabelVerticalInset];
        [self.messageDeliveryStatusLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                                          withInset:kMessageDeliveryStatusLabelHorizontalInset];
        [self.messageDeliveryStatusLabel autoSetDimension:ALDimensionWidth
                                                   toSize:kMessageDeliveryStatusLabelSizeWidth];
        [self.messageDeliveryStatusLabel autoSetDimension:ALDimensionHeight
                                                   toSize:kMessageDeliveryStatusLabelSizeHeight];
        self.messageDeliveryStatusLabel.textAlignment = NSTextAlignmentCenter;
        
        //    user Avatar Background Image
        [self.userAvatarBgView autoPinEdgeToSuperviewEdge:ALEdgeRight
                                                withInset:kUserAvatarBgImgViewHorizontalInset];
        [self.userAvatarBgView autoPinEdge:ALEdgeTop
                                    toEdge:ALEdgeTop
                                    ofView:self.messageBgView
                                withOffset:kUserAvatarBgImgViewVerticalInset];
        [self.userAvatarBgView autoSetDimension:ALDimensionWidth
                                         toSize:kUserAvatarBgImgSizeWidth];
        [self.userAvatarBgView autoSetDimension:ALDimensionHeight
                                         toSize:kUserAvatarBgImgSizeHeight];
        
        //    user Avatar Image
        [self.userAvatarImgView autoPinEdge:ALEdgeRight
                                     toEdge:ALEdgeRight
                                     ofView:self.userAvatarBgView
                                 withOffset:1];
        [self.userAvatarImgView autoPinEdge:ALEdgeTop
                                     toEdge:ALEdgeTop
                                     ofView:self.userAvatarBgView
                                 withOffset:1];
        [self.userAvatarImgView autoSetDimension:ALDimensionWidth
                                          toSize:kUserAvatarBgImgSizeWidth-1];
        [self.userAvatarImgView autoSetDimension:ALDimensionHeight
                                          toSize:kUserAvatarBgImgSizeHeight-1];
        
        //    user Name Label
        [self.userNameLbl autoPinEdge:ALEdgeRight
                               toEdge:ALEdgeRight
                               ofView:self.userAvatarBgView
                           withOffset:kUserNameViewHoriWidthMargin];
        [self.userNameLbl autoPinEdge:ALEdgeTop
                               toEdge:ALEdgeBottom
                               ofView:self.userAvatarBgView
                           withOffset:kUserNameViewVerticalInset];
        [self.userNameLbl autoSetDimension:ALDimensionWidth
                                    toSize:kUserAvatarBgImgSizeWidth + (2 * kUserNameViewHoriWidthMargin)];
        [self.userNameLbl autoSetDimension:ALDimensionHeight
                                    toSize:kUserNameViewSizeHeight];
        
        //        message sent time
        [self.messageSentTimeLbl autoPinEdgeToSuperviewEdge:ALEdgeTop
                                                  withInset:kMessageTimeLabelVerticalInset];
        [self.messageSentTimeLbl autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                  withInset:kMessageTimeLabelHorizontalInset];
        [self.messageSentTimeLbl autoSetDimension:ALDimensionWidth
                                           toSize:kMessageTimeLabelSizeWidth];
        [self.messageSentTimeLbl autoSetDimension:ALDimensionHeight
                                           toSize:kMessageTimeLabelSizeHeight];
        self.messageSentTimeLbl.textAlignment = NSTextAlignmentLeft;
        
        //    message background view
        [self.messageBgView setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                            forAxis:UILayoutConstraintAxisVertical];
        [self.messageBgView autoPinEdge:ALEdgeTop
                                 toEdge:ALEdgeBottom
                                 ofView:self.messageSentTimeLbl
                             withOffset:kMessageBgImgViewVerticalOffset];
        
        
        [self.messageBgView autoPinEdge:ALEdgeRight
                                 toEdge:ALEdgeLeft
                                 ofView:self.userAvatarImgView
                             withOffset:-kMessageBgImgViewHorizontalMargin];
        
        NSString *msgBubbleImagName = nil;
        msgBubbleImagName = @"bg_chatmessage";
        self.messageLbl.alpha = 1.0;
        self.messageBgView.image = [UIImage stretchableImageWithName:msgBubbleImagName
                                                           extension:@"png"
                                                              topCap:20
                                                             leftCap:8
                                                           bottomCap:13
                                                         andRightCap:26];
        
        if (self.messageLbl.text.length >0)
        {
            //            text message
            [self.messageLbl setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                             forAxis:UILayoutConstraintAxisVertical];
            [self.messageLbl autoPinEdge:ALEdgeTop
                                  toEdge:ALEdgeTop
                                  ofView:self.messageBgView
                              withOffset:kMessageLabelVerticalOffset];
            [self.messageLbl autoPinEdge:ALEdgeLeft
                                  toEdge:ALEdgeLeft
                                  ofView:self.messageBgView
                              withOffset:kMessageLabelHorizontalOffset];
            
            CGSize messageSize = [self getSizeforText:self.messageLbl.text];
            int numOfLines = messageSize.height/13.8;
            [self.messageLbl autoSetDimension:ALDimensionWidth toSize:messageSize.width+2.0];
            [self.messageLbl autoSetDimension:ALDimensionHeight toSize:messageSize.height+numOfLines];
            
            [self.messageBgView autoSetDimension:ALDimensionHeight toSize:messageSize.height+12.0];
            [self.messageBgView autoSetDimension:ALDimensionWidth toSize:messageSize.width+20.0];
        }
        else if(self.messageImage != nil)
        {
            //            image message
            [self.messageImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                    withInset:kMultimediaMessageHorizontalInset];
            [self.messageImageView autoPinEdgeToSuperviewEdge:ALEdgeTop
                                                    withInset:kMultimediaMessageVerticalInset];
            
            CGSize imageSize = self.messageImage.size;
            imageSize.height = [[self class] getImageHeight:self.messageImage];
            
            if (imageSize.width > MAXIMUM_IMAGE_SIZE_WIDHT)
                imageSize.width = MAXIMUM_IMAGE_SIZE_WIDHT;
            
            //            imageSize.width = MAXIMUM_IMAGE_SIZE_WIDTH;
            //            imageSize.height = MAXIMUM_IMAGE_SIZE_HEIGHT;
            
            [self.messageImageView autoSetDimension:ALDimensionWidth toSize:imageSize.width];
            [self.messageImageView autoSetDimension:ALDimensionHeight toSize:imageSize.height];
            
            self.messageImageView.image = self.messageImage;
            
            [self.messageBgView autoSetDimension:ALDimensionWidth toSize:imageSize.width+18.0];
            [self.messageBgView autoSetDimension:ALDimensionHeight toSize:imageSize.height+16.0];
        }
        else if (self.messageVideoPath != nil && self.messageVideoPath.length > 0)
        {
            //            video message
            [self.videoThumbImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                       withInset:kMultimediaMessageHorizontalInset];
            [self.videoThumbImageView autoPinEdgeToSuperviewEdge:ALEdgeTop
                                                       withInset:kMultimediaMessageVerticalInset];
            [self.videoThumbImageView autoSetDimension:ALDimensionWidth
                                                toSize:VIDEO_FRAME_WIDTH];
            [self.videoThumbImageView autoSetDimension:ALDimensionHeight
                                                toSize:VIDEO_FRAME_HEIGHT];
            
            self.moviePlayerController.view.frame = CGRectMake(kMultimediaMessageHorizontalInset,
                                                               kMultimediaMessageVerticalInset,
                                                               VIDEO_FRAME_WIDTH,
                                                               VIDEO_FRAME_HEIGHT);
            
            [self.messageBgView autoSetDimension:ALDimensionWidth
                                          toSize:VIDEO_FRAME_WIDTH+18.0];
            [self.messageBgView autoSetDimension:ALDimensionHeight
                                          toSize:VIDEO_FRAME_HEIGHT+16.0];
            
            [self.moviePlayerController setContentURL:[NSURL fileURLWithPath:self.messageVideoPath]];
            [self.moviePlayerController prepareToPlay];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleThumbnailImageRequestFinishNotification:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                                       object:self.moviePlayerController];
            [self.moviePlayerController requestThumbnailImagesAtTimes:@[[NSNumber numberWithFloat:THUMBNAIL_IMAGE_AT_TIME_INTERVEL]]
                                                           timeOption:MPMovieTimeOptionNearestKeyFrame];
        }
        self.didSetUpSentConstraints = YES;
    }
    else
    {
        if (self.didSetUpReceivedConstraints) {
            return;
        }
        
        //    user Avatar Background Image
        [self.userAvatarBgView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                withInset:kUserAvatarBgImgViewHorizontalInset];
        [self.userAvatarBgView autoPinEdge:ALEdgeTop
                                    toEdge:ALEdgeTop
                                    ofView:self.messageBgView
                                withOffset:kUserAvatarBgImgViewVerticalInset];
        [self.userAvatarBgView autoSetDimension:ALDimensionWidth
                                         toSize:kUserAvatarBgImgSizeWidth];
        [self.userAvatarBgView autoSetDimension:ALDimensionHeight
                                         toSize:kUserAvatarBgImgSizeHeight];
        
        //    user Avatar Image
        [self.userAvatarImgView autoPinEdge:ALEdgeLeft
                                     toEdge:ALEdgeLeft
                                     ofView:self.userAvatarBgView
                                 withOffset:1];
        [self.userAvatarImgView autoPinEdge:ALEdgeTop
                                     toEdge:ALEdgeTop
                                     ofView:self.userAvatarBgView
                                 withOffset:1];
        [self.userAvatarImgView autoSetDimension:ALDimensionWidth
                                          toSize:kUserAvatarBgImgSizeWidth-1];
        [self.userAvatarImgView autoSetDimension:ALDimensionHeight
                                          toSize:kUserAvatarBgImgSizeHeight-1];
        
        
        //    user Name Label
        [self.userNameLbl autoPinEdge:ALEdgeLeft
                               toEdge:ALEdgeLeft
                               ofView:self.userAvatarBgView
                           withOffset:-kUserNameViewHoriWidthMargin];
        [self.userNameLbl autoPinEdge:ALEdgeTop
                               toEdge:ALEdgeBottom
                               ofView:self.userAvatarBgView
                           withOffset:kUserNameViewVerticalInset];
        [self.userNameLbl autoSetDimension:ALDimensionWidth
                                    toSize:kUserAvatarBgImgSizeWidth + (2 * kUserNameViewHoriWidthMargin)];
        [self.userNameLbl autoSetDimension:ALDimensionHeight
                                    toSize:kUserNameViewSizeHeight];
        
        //        message sent time
        [self.messageSentTimeLbl autoPinEdgeToSuperviewEdge:ALEdgeTop
                                                  withInset:kMessageTimeLabelVerticalInset];
        [self.messageSentTimeLbl autoPinEdgeToSuperviewEdge:ALEdgeRight
                                                  withInset:kMessageTimeLabelHorizontalInset];
        [self.messageSentTimeLbl autoSetDimension:ALDimensionWidth
                                           toSize:kMessageTimeLabelSizeWidth];
        [self.messageSentTimeLbl autoSetDimension:ALDimensionHeight
                                           toSize:kMessageTimeLabelSizeHeight];
        self.messageSentTimeLbl.textAlignment = NSTextAlignmentRight;
        
        //    message background view
        [self.messageBgView setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                            forAxis:UILayoutConstraintAxisVertical];
        [self.messageBgView autoPinEdge:ALEdgeTop
                                 toEdge:ALEdgeBottom
                                 ofView:self.messageSentTimeLbl
                             withOffset:kMessageBgImgViewVerticalOffset];
        
        [self.messageBgView autoPinEdge:ALEdgeLeft
                                 toEdge:ALEdgeRight
                                 ofView:self.userAvatarImgView
                             withOffset:kMessageBgImgViewHorizontalMargin];
        
        self.messageBgView.image = [UIImage stretchableImageWithName:@"bg_chatmessage_others"
                                                           extension:@"png"
                                                              topCap:22
                                                             leftCap:10
                                                           bottomCap:13
                                                         andRightCap:26];
        
        if (self.messageLbl.text.length >0)
        {
            //    text message Label
            [self.messageLbl setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                             forAxis:UILayoutConstraintAxisVertical];
            [self.messageLbl autoPinEdge:ALEdgeTop
                                  toEdge:ALEdgeTop
                                  ofView:self.messageBgView
                              withOffset:kMessageLabelVerticalOffset];
            
            [self.messageLbl autoPinEdge:ALEdgeLeft
                                  toEdge:ALEdgeLeft
                                  ofView:self.messageBgView
                              withOffset:5 + kMessageLabelHorizontalOffset];
            
            CGSize messageSize = [self getSizeforText:self.messageLbl.text];
            [self.messageLbl autoSetDimension:ALDimensionWidth toSize:messageSize.width+2.0];
            [self.messageLbl autoSetDimension:ALDimensionHeight toSize:messageSize.height+2.0];
            
            [self.messageBgView autoSetDimension:ALDimensionHeight toSize:messageSize.height+12.0];
            [self.messageBgView autoSetDimension:ALDimensionWidth toSize:messageSize.width+20.0];
        }
        else if (self.messageImage != nil)
        {
            //            image message
            [self.messageImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                    withInset:kMultimediaMessageHorizontalInset+5.0];
            [self.messageImageView autoPinEdgeToSuperviewEdge:ALEdgeTop
                                                    withInset:kMultimediaMessageVerticalInset];
            
            CGSize imageSize = self.messageImage.size;
            imageSize.height = [[self class] getImageHeight:self.messageImage];
            
            if (imageSize.width > MAXIMUM_IMAGE_SIZE_WIDHT)
                imageSize.width = MAXIMUM_IMAGE_SIZE_WIDHT;
            
            [self.messageImageView autoSetDimension:ALDimensionWidth toSize:imageSize.width];
            [self.messageImageView autoSetDimension:ALDimensionHeight toSize:imageSize.height];
            
            self.messageImageView.image = self.messageImage;
            
            [self.messageBgView autoSetDimension:ALDimensionWidth toSize:imageSize.width+18.0];
            [self.messageBgView autoSetDimension:ALDimensionHeight toSize:imageSize.height+16.0];
        }
        else if (self.messageVideoPath != nil && self.messageVideoPath.length > 0)
        {
            //            video message
            [self.videoThumbImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                       withInset:kMultimediaMessageHorizontalInset+6.0];
            [self.videoThumbImageView autoPinEdgeToSuperviewEdge:ALEdgeTop
                                                       withInset:kMultimediaMessageVerticalInset];
            [self.videoThumbImageView autoSetDimension:ALDimensionWidth toSize:VIDEO_FRAME_WIDTH];
            [self.videoThumbImageView autoSetDimension:ALDimensionHeight toSize:VIDEO_FRAME_HEIGHT];
            
            self.moviePlayerController.view.frame = CGRectMake(kMultimediaMessageHorizontalInset+6.0,
                                                               kMultimediaMessageVerticalInset,
                                                               VIDEO_FRAME_WIDTH,
                                                               VIDEO_FRAME_HEIGHT);
            
            [self.messageBgView autoSetDimension:ALDimensionWidth toSize:VIDEO_FRAME_WIDTH+18.0];
            [self.messageBgView autoSetDimension:ALDimensionHeight toSize:VIDEO_FRAME_HEIGHT+16.0];
            
            [self.moviePlayerController setContentURL:[NSURL fileURLWithPath:self.messageVideoPath]];
            [self.moviePlayerController prepareToPlay];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleThumbnailImageRequestFinishNotification:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                                       object:self.moviePlayerController];
            [self.moviePlayerController requestThumbnailImagesAtTimes:@[[NSNumber numberWithFloat:THUMBNAIL_IMAGE_AT_TIME_INTERVEL]]
                                                           timeOption:MPMovieTimeOptionNearestKeyFrame];
        }
        self.didSetUpReceivedConstraints = YES;
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self.contentView setNeedsDisplay];
    [self.contentView layoutIfNeeded];
    
    self.messageLbl.preferredMaxLayoutWidth = CGRectGetWidth(self.messageLbl.frame);
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    [self.contentView autoRemoveConstraintsAffectingViewAndSubviews];
    self.didSetUpReceivedConstraints = NO;
    self.didSetUpSentConstraints = NO;
}

-(void) handleThumbnailImageRequestFinishNotification:(NSNotification*)notifiation
{
    NSDictionary *userinfo = [notifiation userInfo];
    NSError* value = [userinfo objectForKey:MPMoviePlayerThumbnailErrorKey];
    
    if (value!=nil)
    {
        NSLog(@"Error: %@", [value debugDescription]);
    }
    else
    {
        self.videoThumbImageView.image = [userinfo valueForKey:MPMoviePlayerThumbnailImageKey];
        [self.moviePlayerController stop];
        [self.moviePlayerController.view setHidden:YES];
    }
}

#pragma mark - public method
-(CGSize) getSizeforText:(NSString *)message
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        context.minimumScaleFactor = 0.8;
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:12.0];
        CGRect frame = [message boundingRectWithSize:CGSizeMake((self.contentView.frame.size.width - 110.0), 2000)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{ NSFontAttributeName : font}
                                             context:context];
        return frame.size;

    }
    else{
        CGSize size = [message sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]
                          constrainedToSize:CGSizeMake((self.contentView.frame.size.width - 110.0), 2000)
                              lineBreakMode:NSLineBreakByWordWrapping];
        return size;
    }
}

-(void) playOrPauseVideo
{
    [self.videoThumbImageView setHidden:YES];
    [self.moviePlayerController.view setHidden:NO];
    [self.moviePlayerController play];
}

+(CGFloat) getImageHeight:(UIImage *)image
{
    if (image.size.width > MAXIMUM_IMAGE_SIZE_WIDHT)
    {
        CGFloat scallingFactor = MAXIMUM_IMAGE_SIZE_WIDHT / image.size.width;
        CGFloat imageHeight = image.size.height * scallingFactor;
        return ceilf(imageHeight);
    }
    else
        return image.size.height;
}

@end
