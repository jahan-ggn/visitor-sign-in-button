import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const router = api.container.lookup("service:router");

  if (
    !settings.visitor_signin_button_text ||
    !settings.visitor_signin_button_url
  ) {
    return;
  }

  function createButton() {
    const button = document.createElement("button");
    button.className = "btn btn-primary visitor-signin-button";
    button.type = "button";

    const span = document.createElement("span");
    span.className = "d-button-label";
    span.textContent = settings.visitor_signin_button_text;

    button.appendChild(span);

    button.addEventListener("click", () => {
      router.transitionTo(settings.visitor_signin_button_url);
    });

    return button;
  }

  function injectButton(container) {
    if (!container || container.querySelector(".visitor-signin-button")) {
      return;
    }

    const signupButton = container.querySelector(".sign-up-button");
    if (!signupButton) {
      return;
    }

    let buttonRow = container.querySelector(".visitor-button-row");

    if (!buttonRow) {
      buttonRow = document.createElement("div");
      buttonRow.className = "visitor-button-row";

      const paragraph = container.querySelector("p:last-of-type");

      if (paragraph) {
        paragraph.insertAdjacentElement("afterend", buttonRow);
      } else {
        container.appendChild(buttonRow);
      }

      buttonRow.appendChild(signupButton);
    }

    buttonRow.appendChild(createButton());
  }

  function handleNode(node) {
    if (!(node instanceof HTMLElement)) {
      return;
    }

    if (node.matches(".fkb-panel .visitor")) {
      injectButton(node);
      return;
    }

    const container = node.querySelector(".fkb-panel .visitor");
    if (container) {
      injectButton(container);
    }
  }

  function scanExisting() {
    document.querySelectorAll(".fkb-panel .visitor").forEach(injectButton);
  }

  api.onPageChange(scanExisting);

  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        handleNode(node);
      }
    }
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });
});
