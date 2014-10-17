/*
 All rights reserved.
 
 Permission to use, copy, modify, and distribute this software
 for any purpose with or without fee is hereby granted, provided
 that the above copyright notice and this permission notice
 appear in all copies.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Except as contained in this notice, the name of a copyright
 holder shall not be used in advertising or otherwise to promote
 the sale, use or other dealings in this Software without prior
 written authorization of the copyright holder.
 */

#import "CustomLabel.h"
#import <CoreText/CoreText.h>

@implementation CustomLabel

@synthesize stringColor;
@synthesize keywordColor;
@synthesize list;

-(id) init
{
    if (self = [super init]) {
        self.text = nil;
        stringColor = nil;
        keywordColor = nil;
        list = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.text = nil;
        stringColor = nil;
        keywordColor = nil;
        list = [[NSMutableArray alloc] init];
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [list release];
    [super dealloc];
}

//设置字体颜色和关键字的颜色
- (void) setUIlabelTextColor:(UIColor *) strColor 
                 andKeyWordColor: (UIColor *) keyColor
{
    self.stringColor = strColor;
    self.keywordColor = keyColor;
}


//设置颜色属性和字体属性
- (NSAttributedString *)illuminatedString:(NSString *)text 
                                     font:(UIFont *)AtFont{
    BOOL outFlag=NO;
	NSMutableString* mStr = [[NSMutableString alloc] initWithString:text];
    CGSize size = [mStr sizeWithFont:self.font];
    CGSize size_Point = [@"..." sizeWithFont:self.font];
    if(size.width > self.frame.size.width){
        while (size.width+size_Point.width > self.frame.size.width) {
            NSRange range;
            range.length=1;
            range.location = [mStr length]-1;
            [mStr deleteCharactersInRange: range];
            size = [mStr sizeWithFont:self.font];
            outFlag = YES;
        }
        [mStr appendString:@"..."];
    }
    int len = [mStr length]; 
    //创建一个可变的属性字符串
    NSMutableAttributedString *mutaString = [[[NSMutableAttributedString alloc] initWithString:mStr] autorelease];
    //改变字符串 从1位 长度为1 这一段的前景色，即字的颜色。
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)self.stringColor.CGColor
                       range:NSMakeRange(0, len)];
    
  
    
    if (self.keywordColor != nil)
    {
        for (NSValue *value in list) 
        {
            NSRange keyRange = [value rangeValue];
            if (outFlag) 
                if (keyRange.location+keyRange.length > [mStr length]-3) {
                    continue;
                }
            [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                                                    value:(id)self.keywordColor.CGColor
                                                    range:keyRange];
        }
    }

    //设置是否使用连字属性，这里设置为0，表示不使用连字属性。标准的英文连字有FI,FL.默认值为1，既是使用标准连字。也就是当搜索到f时候，会把fl当成一个文字。
    int nNumType = 0;
    CFNumberRef cfNum = CFNumberCreate(NULL, kCFNumberIntType, &nNumType);
    [mutaString addAttribute:(NSString *)kCTLigatureAttributeName
                       value:(id)cfNum
                       range:NSMakeRange(0, len)];
    
    CTFontRef ctFont2 = CTFontCreateWithName((CFStringRef)AtFont.fontName, 
                                             AtFont.pointSize,
                                             NULL);
    [mutaString addAttribute:(NSString *)(kCTFontAttributeName) 
                       value:(id)ctFont2 
                       range:NSMakeRange(0, len)];
    CFRelease(ctFont2);
    CFRelease(cfNum);
    [mStr release];
    return [[mutaString copy] autorelease];
}

//重绘Text
- (void)drawRect:(CGRect)rect 
{
    //获取当前label的上下文以便于之后的绘画，这个是一个离屏。
	CGContextRef context = UIGraphicsGetCurrentContext();
    //压栈，压入图形状态栈中.每个图形上下文维护一个图形状态栈，并不是所有的当前绘画环境的图形状态的元素都被保存。图形状态中不考虑当前路径，所以不保存
    //保存现在得上下文图形状态。不管后续对context上绘制什么都不会影响真正得屏幕。
	CGContextSaveGState(context);
    //x，y轴方向移动
	CGContextTranslateCTM(context, 0.0, 0.0);/*self.bounds.size.height*/
    
    //缩放x，y轴方向缩放，－1.0为反向1.0倍,坐标系转换,沿x轴翻转180度
	CGContextScaleCTM(context, 1, -1);	
	
    if ( self.text.length == 0 )
    {
        return;
    }
       
    
    //创建一个文本行对象，此对象包含一个字符
    NSAttributedString * AttributedString = [self illuminatedString:self.text font:self.font];
    CTLineRef line;
    if (AttributedString) 
        line = CTLineCreateWithAttributedString((CFAttributedStringRef)
                                                     AttributedString);
    //设置文字绘画的起点坐标。由于前面沿x轴翻转了（上面那条边）所以要移动到与此位置相同，也可以只改变CGContextSetTextPosition函数y的坐标，效果是一样的只是意义不一样
          CGContextTranslateCTM(context, 0.0, - ceill(self.bounds.size.height) + 8);//加8是稍微调整一下位置，让字体完全现实，有时候y，j下面一点点会被遮盖
	CGContextSetTextPosition(context, 0.0, 0.0); 
    //在离屏上绘制line
	CTLineDraw(line, context);
    //将离屏上得内容覆盖到屏幕。此处得做法很像windows绘制中的双缓冲。
	CGContextRestoreGState(context);	
	CFRelease(line);
}
@end
