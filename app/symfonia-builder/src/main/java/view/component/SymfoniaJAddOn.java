package view.component;

import java.awt.Color;
import java.awt.Font;
import java.awt.event.ActionListener;
import java.awt.font.TextAttribute;
import java.util.Collections;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JCheckBox;
import javax.swing.JLabel;

import config.Configuration;

/**
 * Erzeugt eine AddOn-Bundle Kachel für gewöhnliche Bundles.
 * 
 * @author totalwarANGEL
 *
 */
@SuppressWarnings("serial")
public class SymfoniaJAddOn extends SymfoniaJPanelGray
{
    /**
     * Id des Bundle (-> Name des Folders)
     */
    protected String id;

    /**
     * Titel des Bundle
     */
    protected JLabel title;

    /**
     * Text des Bundle
     */
    protected JLabel text;

    /**
     * Checkbox
     */
    protected JCheckBox checkbox;

    /**
     * Liste der Abhängigkeiten (-> Name des Folders)
     */
    List<String> dependencies;

    /**
     * Erzeugt eine Bundle-Kachel mit einem bestimmten Titel und einer bestimmten
     * Größe.
     * 
     * @param id Id des Bundle (-> Name des Folders)
     * @param title Titel des Bundle
     * @param text Text des Bundle
     * @param dependencies Liste der Abhängigkeiten (-> Name des Folders)
     * @param x Breite
     * @param y Höhe
     * @param aL Action listener
     */
    public SymfoniaJAddOn(final String id, final String title, final String text, final List<String> dependencies,
            final int x, final int y, final ActionListener aL)
    {
        super(null);
        super.applyConfiguration();
        this.id = id;
        this.dependencies = dependencies;
        setSize(x, y);
        createComponents(title, text, x, y, aL);
    }

    /**
     * Erzeugt die KMomponenten und konfiguriert sie.
     * 
     * @param title Titel des Bundle
     * @param text Text des Bundle
     * @param x Breite
     * @param y Höhe
     * @param aL Action listener
     */
    protected void createComponents(
        final String title,
        final String text,
        final int x,
        final int y,
        final ActionListener aL)
    {
        this.title = new JLabel("<html><b>" + title + "</b></html>");
        this.title.setBounds(40, 5, x - 80, 20);
        this.title.setVisible(true);
        add(this.title);

        this.text = new JLabel("<html><p>" + text + "</p></html>");
        this.text.setBounds(40, 25, x - 80, 50);
        this.text.setVisible(true);
        this.text.setVerticalAlignment(JLabel.TOP);
        this.text.setVerticalTextPosition(JLabel.TOP);
        Font font = this.text.getFont();
        font = font.deriveFont(Collections.singletonMap(TextAttribute.WEIGHT, TextAttribute.WEIGHT_SEMIBOLD));
        this.text.setFont(font);
        add(this.text);

        this.checkbox = new JCheckBox();
        this.checkbox.setBounds(10, 5, 20, 20);
        this.checkbox.setVisible(true);
        this.checkbox.setBackground(Configuration.getColor("defaults.colors.bg.orange"));
        this.checkbox.addActionListener(aL);
        add(this.checkbox);

        final int bw = Configuration.getInteger("defaults.border.width");
        final Color bc = Configuration.getColor("defaults.colors.border.orange");
        setBackground(Configuration.getColor("defaults.colors.bg.orange"));
        setBorder(BorderFactory.createLineBorder(bc, bw));
    }

    /**
     * Gibt die ID des Bundles zurück.
     * 
     * @return ID
     */
    public String getID()
    {
        return id;
    }
    
    /**
     * Gibt die Abhängigkeiten des Bundles zurück.
     * 
     * @return IDs Abhängigkeiten
     */
    public List<String> getDependencies()
    {
        return dependencies;
    }
    
    /**
     * Prüft, ob das Addon von dem Bundle abhängig ist.
     * 
     * @param id ID des Bundles
     * @return IDs Abhängigkeiten
     */
    public boolean dependOn(final String id)
    {
        for (int i=0; i<dependencies.size(); i++) {
            if (dependencies.get(i).equals(id)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Setzt das Selected Flag des Bundles.
     * 
     * @param checked Flag
     */
    public void setChecked(final boolean checked)
    {
        checkbox.setSelected(checked);
    }

    /**
     * Gibt zurück, ob das Bundle ausgewählt ist.
     * 
     * @return Ausgewählt
     */
    public boolean isChecked()
    {
        return checkbox.isSelected();
    }
}
