import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:prbd_2526_c05/core/tools/debounce.dart';

/// Un contrôleur de texte qui étend [TextEditingController] avec des fonctionnalités
/// de validation automatique.
///
/// Ce contrôleur permet de valider le texte saisi par l'utilisateur de manière
/// synchrone et/ou asynchrone. La validation est déclenchée automatiquement lors
/// des modifications du texte. Pour les validations asynchrones, un système de
/// debouncing est utilisé pour éviter les appels multiples inutiles.
///
/// Le contrôleur expose plusieurs propriétés utiles :
/// - [isValidating] : indique si une validation est en cours
/// - [isPristine] : indique si le champ n'a pas encore été modifié par l'utilisateur
/// - [errorText] : le message d'erreur de validation, s'il y en a un
/// - [isValid] : indique si le texte est valide (null si la validation est en cours)
///
/// Exemple d'utilisation :
/// ```dart
/// final controller = ValidatingTextEditingController(
///   validator: (value) => value.isEmpty ? 'Le champ est requis' : null,
///   asyncValidator: (value) async {
///     // Validation asynchrone (ex: vérification serveur)
///     return null;
///   },
///   onAfterValidated: () => setState(() {}),
/// );
/// ```
class ValidatingTextEditingController extends TextEditingController {
  // validateur synchrone
  String? Function(String value)? validator;

  // validateur asynchrone
  Future<String?> Function(String value)? asyncValidator;

  // callback appelé après la validation
  void Function()? onAfterValidated;

  // message d'erreur
  String? _errorText;

  // la validation est en cours
  bool _isValidating = false;

  // le champ est vierge (non modifié par l'utilisateur)
  bool _isPristine = true;

  // le contrôleur a été supprimé
  bool _isDisposed = false;

  // tâche asynchrone en cours
  CancelableOperation? _task;

  // debouncer pour la validation asynchrone
  final Debouncer _debouncer = Debouncer();

  /// Crée un nouveau [ValidatingTextEditingController].
  ///
  /// Le constructeur accepte les paramètres suivants :
  ///
  /// - [validator] : fonction de validation synchrone qui prend la valeur du texte
  ///   et retourne un message d'erreur (String?) ou null si la validation réussit.
  ///   Cette validation est exécutée immédiatement lors des modifications du texte.
  ///
  /// - [asyncValidator] : fonction de validation asynchrone qui prend la valeur du texte
  ///   et retourne un Future<String?> avec un message d'erreur ou null si la validation
  ///   réussit. Cette validation est exécutée après la validation synchrone (si elle
  ///   réussit) et utilise un système de debouncing pour éviter les appels multiples.
  ///
  /// - [onAfterValidated] : callback optionnel appelé après chaque validation (synchrone
  ///   ou asynchrone). Utile pour mettre à jour l'interface utilisateur, par exemple
  ///   en appelant setState().
  ///
  /// - [initialValue] : valeur initiale du texte dans le contrôleur.
  ValidatingTextEditingController({
    this.validator,
    this.asyncValidator,
    this.onAfterValidated,
    initialValue,
  }) : super(text: initialValue);

  bool get isValidating => _isValidating;

  bool get isPristine => _isPristine;

  String? get errorText => _errorText;

  bool? get isValid => _isValidating ? null : (_errorText == null);

  /// On surcharge le setter de [value] pour intercepter les changements de texte
  /// et déclencher la validation.
  @override
  set value(TextEditingValue newValue) {
    if (_isDisposed) return;
    if (newValue.text != text) {
      _isPristine = false;
      super.value = newValue;
      validate();
    } else {
      super.value = newValue;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _task?.cancel();
    _debouncer.cancel();
    super.dispose();
  }

  /// On surcharge la méthode [notifyListeners] pour éviter de notifier les écouteurs
  /// si le contrôleur a été supprimé.
  @override
  notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  /// Cette méthode permet de valider le texte actuel en exécutant les validateurs
  /// synchrone et asynchrone, s'ils sont définis. Le validateur asynchrone est
  /// appelé de manière synchrone (avec un await).
  Future<void> validateAndWait() async {
    if (_isDisposed) return;

    if (validator == null) return;
    _errorText = validator!(text);
    if (asyncValidator != null) {
      _errorText ??= await asyncValidator!(text);
    }
    if (_isDisposed) return;
    notifyListeners();
    onAfterValidated?.call();
  }

  /// Cette méthode permet de valider le texte actuel en exécutant les validateurs
  /// synchrone et asynchrone, s'ils sont définis. Le validateur asynchrone est
  /// appelé de manière asynchrone (sans await). La méthode utilise aussi le
  /// principe de [*debouncing*](https://developer.mozilla.org/en-US/docs/Glossary/Debounce)
  /// pour éviter de lancer plusieurs fois la validation
  /// asynchrone si l'utilisateur appelle plusieurs fois la méthode avant que la
  /// validation précédente ne soit terminée.
  void validate() {
    if (_isDisposed) return;

    _isValidating = true;

    // effectuer la validation synchrone
    _errorText = validator?.call(text);
    notifyListeners();

    // si un validateur asynchrone est défini et la validation synchrone est réussie
    if (asyncValidator != null && _errorText == null) {
      // annuler la tâche en cours, s'il y en a une
      _task?.cancel();

      // utiliser le debouncer pour gérer le délai avant validation asynchrone
      _debouncer.call(() async {
        // vérifier si le contrôleur est toujours actif avant de continuer
        if (_isDisposed) return;

        try {
          // réinitialiser l'erreur avant de valider
          _errorText = null;
          notifyListeners();

          // créer une opération annulable pour la validation asynchrone
          _task = CancelableOperation.fromFuture(asyncValidator!.call(text));

          // attendre le résultat de la validation asynchrone
          final error = await _task?.value;

          // vérifier à nouveau si le contrôleur est toujours actif après l'attente
          if (_isDisposed) return;

          _errorText = error;
        } finally {
          // toujours remettre l'état de validation à false si le contrôleur est actif
          if (!_isDisposed) {
            _isValidating = false;
            notifyListeners();
            onAfterValidated?.call();
          }
        }
      });
    } else {
      // si aucune validation asynchrone n'est nécessaire, remettre l'état immédiatement
      _isValidating = false;
      notifyListeners();
      onAfterValidated?.call();
    }
  }
}
