//
//  AUILiveRoomCommentView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomCommentTableView.h"
#import "AUILiveEdgeInsetLabel.h"
#import "AUIFoundation.h"
#import <Masonry/Masonry.h>


@interface AUILiveRoomCommentView() <AUILiveRoomCommentTableViewDelegate>

@property (strong, nonatomic) AUILiveRoomCommentTableView *internalCommentView;
@property (strong, nonatomic) AUILiveEdgeInsetLabel *unpresentedCommentNotificationLabel;
@property (assign, nonatomic) int32_t commentViewActualHeight;

@end

@implementation AUILiveRoomCommentView

- (AUILiveRoomSystemMessageLabel *)liveSystemMessageLabel {
    
    if (!_liveSystemMessageLabel) {
        _liveSystemMessageLabel = [[AUILiveRoomSystemMessageLabel alloc] init];
        _liveSystemMessageLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        _liveSystemMessageLabel.layer.cornerRadius = 15;
        _liveSystemMessageLabel.layer.masksToBounds = YES;
        _liveSystemMessageLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12];
        _liveSystemMessageLabel.textAlignment = NSTextAlignmentCenter;
        _liveSystemMessageLabel.textColor = [UIColor av_colorWithHexString:@"#FFFFFF" alpha:1.0];
        _liveSystemMessageLabel.alpha = 0.0;
        [self addSubview:_liveSystemMessageLabel];
        [_liveSystemMessageLabel mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.size.mas_equalTo(CGSizeMake(150, 26));
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.internalCommentView.mas_top);
        }];
    }
    return _liveSystemMessageLabel;
}

- (AUILiveRoomCommentTableView *)internalCommentView {
    if (!_internalCommentView) {
        _internalCommentView = [[AUILiveRoomCommentTableView alloc] init];
        _internalCommentView.commentDelegate = self;
        _internalCommentView.alpha = 1.0;
        [self addSubview:_internalCommentView];
        [_internalCommentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
            make.top.equalTo(self.mas_bottom).with.offset(-1);
        }];

        AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
        model.sentContent = @"欢迎大家来到直播间！直播间内严禁出现违法违规、低俗色情、吸烟酗酒等内容，若有违规行为请及时举报。";
        model.sentContentColor = [UIColor av_colorWithHexString:@"#12DBE6" alpha:1.0];
        [_internalCommentView insertNewComment:model presentedCompulsorily:YES];
        
        [_internalCommentView startPresenting];
    }
    return _internalCommentView;
}

- (AUILiveEdgeInsetLabel *)unpresentedCommentNotificationLabel {
    if (!_unpresentedCommentNotificationLabel) {
        _unpresentedCommentNotificationLabel = [[AUILiveEdgeInsetLabel alloc] init];
        _unpresentedCommentNotificationLabel.textInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);
        _unpresentedCommentNotificationLabel.clipsToBounds = YES;
        _unpresentedCommentNotificationLabel.alpha = 0.0;
        _unpresentedCommentNotificationLabel.backgroundColor = [UIColor whiteColor];
        _unpresentedCommentNotificationLabel.layer.cornerRadius = 8.0;
        _unpresentedCommentNotificationLabel.layer.masksToBounds = YES;
        _unpresentedCommentNotificationLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        _unpresentedCommentNotificationLabel.textColor = [UIColor colorWithRed:255/255.0 green:68/255.0 blue:44/255.0 alpha:1/1.0];
        _unpresentedCommentNotificationLabel.userInteractionEnabled = YES;
        [self addSubview:_unpresentedCommentNotificationLabel];
        [_unpresentedCommentNotificationLabel mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(64);
        }];
        
        UIButton* actionButton = [[UIButton alloc] init];
        actionButton.backgroundColor = [UIColor clearColor];
        [_unpresentedCommentNotificationLabel addSubview:actionButton];
        [actionButton addTarget:self action:@selector(onUnpresentedCommentLabelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [actionButton mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.center.equalTo(_unpresentedCommentNotificationLabel);
            make.size.equalTo(_unpresentedCommentNotificationLabel);
        }];
    }
    return _unpresentedCommentNotificationLabel;
}

- (void)setShowComment:(BOOL)showComment {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.internalCommentView.alpha = showComment ? 1.0 : 0.0;
    });
}

- (void)setShowLiveSystemMessage:(BOOL)showLiveSystemMessage {
    _liveSystemMessageLabel.canPresenting = showLiveSystemMessage;
}

- (BOOL)showLiveSystemMessage {
    return _liveSystemMessageLabel.canPresenting;
}

#pragma mark -Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self bringSubviewToFront:self.internalCommentView];
        [self bringSubviewToFront:self.liveSystemMessageLabel];
        [self bringSubviewToFront:self.unpresentedCommentNotificationLabel];
    }
    return self;
}

- (void)dealloc {
    [_internalCommentView stopPresenting];
    [_liveSystemMessageLabel stopPresenting];
}

#pragma mark -Public Methods

- (void)insertLiveSystemMessage:(NSString *)message {
    [self insertLiveSystemMessageModel:({
        AUILiveRoomSystemMessageModel* model = [[AUILiveRoomSystemMessageModel alloc] init];
        model.rawMessage = message;
        model;
    })];
}

- (void)insertLiveSystemMessageModel:(AUILiveRoomSystemMessageModel *)messageModel {
    [self.liveSystemMessageLabel insertLiveSystemMessage:messageModel];
}

- (void)insertLiveComment:(AUILiveRoomCommentModel *)comment presentedCompulsorily:(BOOL)presentedCompulsorily{
    [self.internalCommentView insertNewComment:comment presentedCompulsorily:presentedCompulsorily];
}

- (void)insertLiveComment:(NSString *)content commentSenderNick:(NSString *)nick commentSenderID:(NSString *)userID presentedCompulsorily:(BOOL)presentedCompulsorily{
    AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
    if (nick) {
        model.senderNick = nick;
    }
    model.senderID = userID;
    model.sentContent = content;
    
    [self insertLiveComment:model presentedCompulsorily:presentedCompulsorily];
}

- (void)updateLayoutRotated:(BOOL)rotated {
    if (!rotated){  // 竖屏
        [self mas_remakeConstraints:^(MASConstraintMaker * _Nonnull make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.superview.mas_safeAreaLayoutGuideBottom).with.offset(-59);
                make.left.equalTo(self.superview.mas_safeAreaLayoutGuideLeft).with.offset(10);
            } else {
                make.bottom.equalTo(self.superview).with.offset(-59);
                make.left.equalTo(self.superview.mas_left).with.offset(10);
            }
            make.right.equalTo(self.superview.mas_right).with.offset(-1 * kLiveCommentPortraitRightGap);
            make.height.mas_equalTo(kLiveCommentPortraitHeight);
        }];
        
        [self.internalCommentView mas_updateConstraints:^(MASConstraintMaker * _Nonnull make) {
                make.top.equalTo(self.mas_bottom).with.offset(-1 * MIN(self.commentViewActualHeight, MAX(kLiveCommentPortraitHeight - 28, 0)));
            }];
    } else{ // 横屏
        [self mas_remakeConstraints:^(MASConstraintMaker * _Nonnull make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.superview.mas_safeAreaLayoutGuideBottom).with.offset(-59);
                make.left.equalTo(self.superview.mas_safeAreaLayoutGuideLeft).with.offset(10);
            } else {
                make.bottom.equalTo(self.superview).with.offset(-59);
                make.left.equalTo(self.superview.mas_left).with.offset(10);
            }
            make.right.equalTo(self.superview.mas_right).with.offset(-1 * kLiveCommentLandscapeRightGap);
            make.height.mas_equalTo(kLiveCommentLandscapeHeight);
        }];
        
        [self.internalCommentView mas_updateConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.top.equalTo(self.mas_bottom).with.offset(-1 * MIN(self.commentViewActualHeight, MAX(kLiveCommentLandscapeHeight - 28, 0)));
        }];
    }
}

#pragma mark -unpresentedCommentLabelClicked action

- (void)onUnpresentedCommentLabelClicked:(UIButton *)sender {
    [self.internalCommentView scrollToNewestComment];
}

#pragma mark -AUILiveRoomCommentTableViewDelegate

- (void)actionWhenUnpresentedCommentCountChange:(NSInteger)count {
    if (count > 0) {
        if (self.unpresentedCommentNotificationLabel) {
            self.unpresentedCommentNotificationLabel.text = [NSString stringWithFormat:@"%zd条新消息", count];
            CGSize sizeNew = [self.unpresentedCommentNotificationLabel.text sizeWithAttributes:@{NSFontAttributeName:self.unpresentedCommentNotificationLabel.font}];
            [self.unpresentedCommentNotificationLabel mas_updateConstraints:^(MASConstraintMaker * _Nonnull make) {
                make.width.mas_equalTo(sizeNew.width + 18);
            }];
            self.unpresentedCommentNotificationLabel.alpha = 1.0;
        }
    } else {
        self.unpresentedCommentNotificationLabel.alpha = 0.0;
    }
}

- (void)actionWhenOneCommentPresentedWithActualHeight:(CGFloat)height {
    self.commentViewActualHeight = height;
    
    if (height > self.bounds.size.height - 28) {
        return;
    }
        
    [self.internalCommentView mas_updateConstraints:^(MASConstraintMaker * _Nonnull make) {
        make.top.equalTo(self.mas_bottom).with.offset(-1 * MIN(height, MAX(self.bounds.size.height - 28, 0)));
    }];
    [self layoutIfNeeded];
}

- (void)actionWhenCommentJustAboutToPresent:(AUILiveRoomCommentModel *)model {
    
}

-(void) actionWhenCommentCellLongPressed:(AUILiveRoomCommentModel *)commentModel {

}

-(void) actionWhenCommentCellTapped:(AUILiveRoomCommentModel *)commentModel {

}

@end