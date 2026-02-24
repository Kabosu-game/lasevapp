import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Widget pour afficher un formulaire de paiement Stripe sur web
class StripePaymentWidget extends StatefulWidget {
  final String clientSecret;
  final String publishableKey;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const StripePaymentWidget({
    super.key,
    required this.clientSecret,
    required this.publishableKey,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<StripePaymentWidget> createState() => _StripePaymentWidgetState();
}

class _StripePaymentWidgetState extends State<StripePaymentWidget> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterPayment',
        onMessageReceived: (JavaScriptMessage message) {
          final msg = message.message;
          if (msg.startsWith('success:')) {
            widget.onSuccess();
          } else if (msg.startsWith('error:')) {
            widget.onError(msg.substring(6).trim());
          } else if (msg == 'success') {
            widget.onSuccess();
          } else {
            widget.onError(msg);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('flutter://payment-success')) {
              widget.onSuccess();
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith('flutter://payment-error?')) {
              try {
                final msg = Uri.parse(request.url).queryParameters['msg'] ?? 'Erreur';
                widget.onError(msg);
              } catch (_) {
                widget.onError('Erreur de paiement');
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            widget.onError('Erreur WebView: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_buildPaymentHtml());
  }

  String _buildPaymentHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <script src="https://js.stripe.com/v3/"></script>
      <style>
        body {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
          margin: 0;
          padding: 20px;
          background: #f5f5f5;
        }
        .container {
          max-width: 500px;
          margin: 0 auto;
          background: white;
          padding: 20px;
          border-radius: 8px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
          color: #265533;
          font-size: 20px;
          margin-bottom: 20px;
        }
        #card-element {
          border: 1px solid #e0e0e0;
          padding: 12px;
          border-radius: 4px;
          margin-bottom: 20px;
        }
        button {
          width: 100%;
          padding: 12px;
          background: #265533;
          color: white;
          border: none;
          border-radius: 4px;
          font-size: 16px;
          cursor: pointer;
          transition: background 0.3s;
        }
        button:hover {
          background: #1e4226;
        }
        button:disabled {
          background: #ccc;
          cursor: not-allowed;
        }
        #card-errors {
          color: #fa755a;
          margin-bottom: 15px;
        }
        .spinner {
          color: #265533;
          font-size: 22px;
          text-indent: -99999px;
          margin: auto;
          position: relative;
          width: 20px;
          height: 20px;
          box-shadow: inset 0 0 0 2px;
          -webkit-transform: translateZ(0);
          -ms-transform: translateZ(0);
          transform: translateZ(0);
          -webkit-animation: load8 1.1s infinite linear;
          animation: load8 1.1s infinite linear;
        }
        @keyframes load8 {
          0% { -webkit-transform: rotate(0deg); transform: rotate(0deg); }
          100% { -webkit-transform: rotate(360deg); transform: rotate(360deg); }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Paiement Sécurisé</h1>
        <form id="payment-form">
          <div id="card-element"></div>
          <div id="card-errors" role="alert"></div>
          <button id="submit-button">Payer maintenant</button>
        </form>
      </div>

      <script>
        const stripe = Stripe('${widget.publishableKey}');
        const elements = stripe.elements();
        const cardElement = elements.create('card');
        cardElement.mount('#card-element');

        const cardErrors = document.getElementById('card-errors');
        cardElement.on('change', (event) => {
          if (event.error) {
            cardErrors.textContent = event.error.message;
          } else {
            cardErrors.textContent = '';
          }
        });

        const form = document.getElementById('payment-form');
        const submitButton = document.getElementById('submit-button');

        form.addEventListener('submit', async (e) => {
          e.preventDefault();
          submitButton.disabled = true;

          // Confirmer le paiement avec Stripe
          const { error, paymentIntent } = await stripe.confirmCardPayment(
            '${widget.clientSecret}',
            { payment_method: { card: cardElement } }
          );

          if (error) {
            cardErrors.textContent = error.message;
            submitButton.disabled = false;
            if (typeof FlutterPayment !== 'undefined') {
              FlutterPayment.postMessage('error:' + error.message);
            } else {
              window.location.href = 'flutter://payment-error?msg=' + encodeURIComponent(error.message);
            }
          } else if (paymentIntent.status === 'succeeded') {
            if (typeof FlutterPayment !== 'undefined') {
              FlutterPayment.postMessage('success');
            } else {
              window.location.href = 'flutter://payment-success';
            }
          }
        });
      </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
