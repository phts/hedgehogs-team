import java.awt.*;

import model.*;

public final class LocalTestRendererListener {
    public void beforeDrawScene(Graphics graphics, World world, Game game, double scale) {
    }

    public void afterDrawScene(Graphics graphics, World world, Game game, double scale) {
        graphics.setColor(Color.DARK_GRAY);
        for (Hockeyist hockeyist : world.getHockeyists()) {
            graphics.drawString(String.format("%.2f", Math.sqrt(hockeyist.getSpeedX()*hockeyist.getSpeedX()+hockeyist.getSpeedY()*hockeyist.getSpeedY())),
                               (int) hockeyist.getX() - 40,
                               (int) hockeyist.getY() - 40);
        }
    }
}
