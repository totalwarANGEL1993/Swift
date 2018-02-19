package view.window;

import java.awt.Font;
import java.awt.event.ActionEvent;
import java.util.Vector;

import javax.swing.JLabel;
import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import config.Configuration;
import controller.ViewController;
import view.component.SymfoniaJButton;

/**
 * 
 * @author angermanager
 *
 */
public class OptionSelectionWindow extends AbstractWindow
{
    /**
     * Optionsschalter
     */
    private final Vector<SymfoniaJButton> options;
    
    /**
     * 
     */
    private final JLabel title;
    
    /**
     * 
     */
    private final JLabel text;
    
    /**
     * {@inheritDoc}
     */
    public OptionSelectionWindow(final int w, final int h)
    {
        super(w, h);
        
        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");
        
        final String optionTitle = Configuration.getString("defaults.label.title.option");
        final String optionText = Configuration.getString("defaults.label.text.option");
        
        title = new JLabel(optionTitle);
        title.setHorizontalAlignment(SwingConstants.CENTER);
        title.setBounds(10, 10, w - 20, 30);
        title.setFont(new Font(Font.SANS_SERIF, 1, titleSize));
        title.setVisible(true);
        getRootPane().add(title);
    
        text = new JLabel("<html><div align='justify'>" + optionText + "</div></html>");
        text.setVerticalAlignment(SwingConstants.TOP);
        text.setBounds(10, 50, w - 70, h - 300);
        text.setFont(new Font(Font.SANS_SERIF, 0, textSize));
        text.setVisible(true);
        getRootPane().add(text);
        
        options = new Vector<SymfoniaJButton>();
        for (int i=0; i<5; i++) {
            final String caption = Configuration.getString("defaults.caption.option.option" +(i+1));
            final SymfoniaJButton b = new SymfoniaJButton(caption);
            b.setBounds(60, 150+(i*35), w-120, 30);
            b.addActionListener(this);
            b.setVisible(true);
            getRootPane().add(b);
            options.add(b);
        }
        
        getRootPane().setVisible(false);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE)
    {
        // QSB zusammenstellen
        if (aE.getSource() == options.get(0)) {
            
        }
        
        // Dokumentation anzeigen
        if (aE.getSource() == options.get(1)) {
            ViewController.getInstance().openWebPage("doc/index.html");
        }
        
        // Beispiele anzeigen
        if (aE.getSource() == options.get(2)) {
            
        }
        
        // Basisskripte exportieren
        if (aE.getSource() == options.get(3)) {
            ViewController.getInstance().getWindow("SaveBaseScriptsWindow").show();
            hide();
        }
        
        // Self-Update
        if (aE.getSource() == options.get(4)) {
            ViewController.getInstance().getWindow("SelfUpdateWindow").show();
            hide();
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleValueChanged(final ListSelectionEvent a)
    {
        
    }
}