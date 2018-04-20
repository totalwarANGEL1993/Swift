package twa.symfonia.view.window;

import java.awt.Font;
import java.awt.event.ActionEvent;
import java.io.File;
import java.util.List;

import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;

import org.jdesktop.swingx.JXLabel;

import twa.symfonia.config.Configuration;
import twa.symfonia.controller.ViewController;
import twa.symfonia.model.LoadOrderModel;
import twa.symfonia.service.qsb.QsbPackagingException;
import twa.symfonia.service.qsb.QsbPackagingInterface;
import twa.symfonia.service.xml.XmlReaderInterface;
import twa.symfonia.view.component.SymfoniaJAddOn;
import twa.symfonia.view.component.SymfoniaJBundle;

/**
 * Erzeugt das Speicherfenster für die QSB.
 * 
 * @author totalwarANGEL
 */
public class SaveQsbWindow extends AbstractSaveWindow
{

    /**
     * Option: Basisskripte kopieren
     */
    private final JCheckBox saveScriptsCheckbox;

    /**
     * Option: QSB komprimieren
     */
    private JCheckBox minifyQsbCheckbox;

    /**
     * Option: Beispiele kopieren
     */
    private JCheckBox saveExampleCheckbox;

    /**
     * Option: Dokumentation kopieren
     */
    private JCheckBox copyDocCheckbox;

    /**
     * Service, der die QSB baut
     */
    private QsbPackagingInterface packager;

    /**
     * Constructor
     * 
     * @param w Breite
     * @param h Höhe
     * @param reader XML-Reader
     * @throws WindowException
     */
    public SaveQsbWindow(final int w, final int h, final XmlReaderInterface reader) throws WindowException
    {
        super(w, h, reader);

        final int titleSize = Configuration.getInteger("defaults.font.title.size");
        final int textSize = Configuration.getInteger("defaults.font.text.size");

        try
        {
            final String saveTitle = this.reader.getString("UiText/CaptionSaveQsbWindow");
            final String saveText = this.reader.getString("UiText/DescriptionSaveQsbWindow");

            final JXLabel title = new JXLabel(saveTitle);
            title.setHorizontalAlignment(SwingConstants.CENTER);
            title.setBounds(10, 10, w - 20, 30);
            title.setFont(new Font(Font.SANS_SERIF, 1, titleSize));
            title.setVisible(true);
            getRootPane().add(title);

            final JXLabel text = new JXLabel(saveText);
            text.setLineWrap(true);
            text.setVerticalAlignment(SwingConstants.TOP);
            text.setBounds(10, 50, w - 70, h - 300);
            text.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            text.setVisible(true);
            getRootPane().add(text);

            // Options ////////////////////////////////////////

            final String useBaseScripts = this.reader.getString("UiText/SaveBaseScripts");
            final String useExampleScripts = this.reader.getString("UiText/SaveExampleScripts");
            final String useMinifyQsb = this.reader.getString("UiText/MinifyQsbScript");
            final String useCopyDocu = this.reader.getString("UiText/CopyDocumentation");

            saveScriptsCheckbox = new JCheckBox();
            saveScriptsCheckbox.setBounds(40, h - 140, 20, 20);
            saveScriptsCheckbox.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            saveScriptsCheckbox.setVisible(true);
            getRootPane().add(saveScriptsCheckbox);

            final JLabel saveScriptLabel = new JLabel(useBaseScripts);
            saveScriptLabel.setBounds(65, h - 140, w - 110, 20);
            saveScriptLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            saveScriptLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            saveScriptLabel.setVisible(true);
            getRootPane().add(saveScriptLabel);

            saveExampleCheckbox = new JCheckBox();
            saveExampleCheckbox.setBounds(40, h - 160, 20, 20);
            saveExampleCheckbox.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            saveExampleCheckbox.setVisible(true);
            getRootPane().add(saveExampleCheckbox);

            final JLabel saveExampleLabel = new JLabel(useExampleScripts);
            saveExampleLabel.setBounds(65, h - 160, w - 110, 20);
            saveExampleLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            saveExampleLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            saveExampleLabel.setVisible(true);
            getRootPane().add(saveExampleLabel);

            minifyQsbCheckbox = new JCheckBox();
            minifyQsbCheckbox.setBounds(40, h - 180, 20, 20);
            minifyQsbCheckbox.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            minifyQsbCheckbox.setVisible(true);
            getRootPane().add(minifyQsbCheckbox);

            final JLabel minifyQsbLabel = new JLabel(useMinifyQsb);
            minifyQsbLabel.setBounds(65, h - 180, w - 110, 20);
            minifyQsbLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            minifyQsbLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            minifyQsbLabel.setVisible(true);
            getRootPane().add(minifyQsbLabel);

            copyDocCheckbox = new JCheckBox();
            copyDocCheckbox.setBounds(40, h - 120, 20, 20);
            copyDocCheckbox.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            copyDocCheckbox.setVisible(true);
            getRootPane().add(copyDocCheckbox);

            final JLabel copyDocLabel = new JLabel(useCopyDocu);
            copyDocLabel.setBounds(65, h - 120, w - 110, 20);
            copyDocLabel.setFont(new Font(Font.SANS_SERIF, 0, textSize));
            copyDocLabel.setBackground(Configuration.getColor("defaults.colors.bg.normal"));
            copyDocLabel.setVisible(true);
            getRootPane().add(copyDocLabel);

            fileNameField.setText(fileNameField.getText() + "/Symfonia");

            // Not implemented
            saveExampleCheckbox.setEnabled(false);
            minifyQsbCheckbox.setEnabled(false);
        } catch (final Exception e)
        {
            throw new WindowException(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void onSelectionFinished(File selected)
    {
        selected = (selected == null) ? new File(".") : selected;
        fileNameField.setText(unixfyPath(selected.getAbsolutePath()) + "/Symfonia");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleActionEvent(final ActionEvent aE) throws WindowException
    {
        // QSB zusammenstellen
        if (aE.getSource() == save)
        {
            final List<String> files = null;

            try
            {
                packager.pack(
                    getScriptFiles(), fileNameField.getText(), copyDocCheckbox.isSelected(),
                    saveScriptsCheckbox.isSelected(),
                    saveExampleCheckbox.isSelected(), minifyQsbCheckbox.isSelected()
                );
            } catch (final QsbPackagingException e)
            {
                throw new WindowException(e);
            }
        }

        // Zurück
        if (aE.getSource() == back)
        {
            ViewController.getInstance().getWindow("AddOnSelectionWindow").show();
            hide();
        }

        // Ziel auswählen
        if (aE.getSource() == choose)
        {
            ViewController.getInstance().chooseFolder(this);
        }

    }

    /**
     * Gibt die Liste der zu ladenden Quelldateien zurück.
     * 
     * @return Load Order
     */
    private LoadOrderModel getScriptFiles()
    {
        final LoadOrderModel loadOrder = new LoadOrderModel();
        loadOrder.add("/core.lua");

        // Bundles
        final BundleSelectionWindow bundleWindow = (BundleSelectionWindow) ViewController.getInstance().getWindow(
            "BundleSelectionWindow"
        );
        for (final SymfoniaJBundle b : bundleWindow.getBundleList())
        {
            if (b.isChecked())
            {
                loadOrder.add("/bundles/" + b.getID() + "/source.lua");
            }
        }

        // AddOns
        final AddOnSelectionWindow addOnWindow = (AddOnSelectionWindow) ViewController.getInstance()
            .getWindow("AddOnSelectionWindow");

        for (final SymfoniaJAddOn a : addOnWindow.getBundleList())
        {
            handleAddOnScriptDependencies(addOnWindow, a, loadOrder);
        }
        return loadOrder;
    }

    /**
     * Fügt ein AddOn und alle seine Dependencies der Liste der Quelldateien hinzu.
     * 
     * @param addOnWindow AddOn-Auswahlfenster
     * @param addOn AddOn, das geprüft wird.
     * @param files Liste der Bundles
     */
    private void handleAddOnScriptDependencies(
        final AddOnSelectionWindow addOnWindow,
        final SymfoniaJAddOn addOn,
        final LoadOrderModel loadOrder
    )
    {
        if (addOn.isChecked())
        {
            // Benötigte Bundles sind immer da, wenn das AddOn auswählbar ist. AddOns
            // hingegen müssen geprüft werden.
            for (final String dependency : addOn.getDependencies())
            {
                if (dependency.contains("addon"))
                {
                    final SymfoniaJBundle addon = addOnWindow.getBundleScrollPane().getBundle(dependency);
                    handleAddOnScriptDependencies(addOnWindow, addOn, loadOrder);
                }
            }

            // Quelldatei hinzufügen.
            final String fileName = "/addons/" + addOn.getID() + "/source.lua";
            if (!loadOrder.isInside(fileName)) {
                loadOrder.add(fileName);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void handleValueChanged(final ListSelectionEvent a)
    {
    }

    /**
     * Setzt den QSB-Builder.
     * 
     * @param packager QSB-Builder
     */
    public void setPackager(final QsbPackagingInterface packager)
    {
        this.packager = packager;
    }

}
