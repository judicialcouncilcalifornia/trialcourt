<?php

namespace Drupal\jcc_messaging_center\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

/**
 * Settings Form for Messaging center.
 */
class SettingsForm extends ConfigFormBase {

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'jcc_messaging_center_settings';
  }

  /**
   * {@inheritdoc}
   */
  protected function getEditableConfigNames() {
    return [
      'jcc_messaging_center.settings',
    ];
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
    $config = $this->config('jcc_messaging_center.settings');

    $types = \Drupal::entityTypeManager()
      ->getStorage('node_type')
      ->loadMultiple();

    $default_value = [];
    if($config->get('messaging_content_types') != NULL){
      $default_value = $config->get('messaging_content_types');
    }
    $default_value['custom_email'] = 'custom_email';

    $footer_form_value = FALSE;
    if($config->get('messaging_display_footer_form') != NULL){
      $footer_form_value = $config->get('messaging_display_footer_form');
    }

    $types_options = [];
    foreach ($types as $node_type) {
      $types_options[$node_type->id()] = $node_type->label();
    }

    $form_state->setCached(FALSE);

    $form['text_header'] = array
    (
      '#prefix' => '<p>',
      '#suffix' => '</p>',
      '#markup' => t('The messaging feature lets you send email notifications to specific mailing groups when an entity on the site is edited/created. <br>Pick which content type should have the option available. <br>If selected, the editing page of each node from this content type will have a "Messaging options" tab appear.'),
    );

    $form['messaging_content_types'] = array(
      '#type' => 'checkboxes',
      '#title' => t('Content types available for email notification'),
      '#options' => $types_options,
      '#default_value' => $default_value,
    );

    $form['messaging_display_footer_form'] = array(
      '#type' => 'checkbox',
      '#title' => t('Display user subscription form in footer'),
      "#default_value" => $footer_form_value,
    );

    $form['messaging_helper'] = array
    (
      '#markup' => t('<strong>Useful links :</strong><ul>
        <li><a href="/admin/structure/taxonomy/manage/user_groups/overview">Manage mailing groups (Taxonomy)</a></li>
        <li><a href="/admin/messenger/group-overview">Users and groups dashboard</a></li>
        </ul>'),
    );

    return parent::buildForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    /* @var $config \Drupal\Core\Config\Config */
    $config = $this->configFactory->getEditable('jcc_messaging_center.settings');

    $config->set('messaging_content_types', $form_state->getValue('messaging_content_types'))->save();
    $config->set('messaging_display_footer_form', $form_state->getValue('messaging_display_footer_form'))->save();

    parent::submitForm($form, $form_state);
  }

}
