public class RectBtn {
   int x;
   int y;
   int w;
   int h;
   int v1;
   int v2;
   int v3;
   int alpha;
   int hoverV1;
   int hoverV2;
   int hoverV3;
   PFont font;
   String label;
   
   public RectBtn(){}
   
   public RectBtn(int x, int y, int w, int h, int v1, int v2, int v3, int alpha, PFont font, String label)
   {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
    this.alpha = alpha;
    this.hoverV1 = v1;
    this.hoverV2 = v2;
    this.hoverV3 = v3;
    this.font = font;
    this.label = label;
   }
   
   public RectBtn(int x, int y, int w, int h, int v1, int v2, int v3, int alpha, int hoverV1, int hoverV2, int hoverV3, PFont font, String label)
   {
    this(x, y, w, h, v1, v2, v3, alpha, font, label);
    this.hoverV1 = hoverV1;
    this.hoverV2 = hoverV2;
    this.hoverV3 = hoverV3;
   }
   
   void setLabel(String label) { this.label = label; }
   
  boolean isOverBtn(){
    if (mouseX >= x - w / 2 && mouseX <= x + w / 2 && mouseY >= y - h / 2 && mouseY <= y + h / 2){
      return true;
    }
    return false;
  }
  
  public void drawBtn(){
    
    stroke(v1, v2, v3, alpha);
    if (isOverBtn()) fill(v1, v2, v3);
    else fill(hoverV1, hoverV2, hoverV3, alpha);
    rect(x, y, w, h);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    textFont(font);
    text(label, x, y);
  }
}
