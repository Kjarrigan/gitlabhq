<script>
const buttonVariants = ['danger', 'primary', 'success', 'warning'];

export default {
  name: 'GlModal',

  props: {
    id: {
      type: String,
      required: false,
      default: null,
    },
    headerTitleText: {
      type: String,
      required: false,
      default: '',
    },
    footerPrimaryButtonVariant: {
      type: String,
      required: false,
      default: 'primary',
      validator: value => buttonVariants.includes(value),
    },
    footerPrimaryButtonText: {
      type: String,
      required: false,
      default: '',
    },
  },

  methods: {
    emitCancel(event) {
      this.$emit('cancel', event);
    },
    emitSubmit(event) {
      this.$emit('submit', event);
    },
  },
};
</script>

<template>
  <div
    :id="id"
    class="modal fade"
    tabindex="-1"
    role="dialog"
  >
    <div
      class="modal-dialog"
      role="document"
    >
      <div class="modal-content">
        <div class="modal-header">
          <slot name="header">
            <h4 class="modal-title">
              <slot name="title">
                {{ headerTitleText }}
              </slot>
            </h4>
            <button
              type="button"
              class="close js-modal-close-action"
              data-dismiss="modal"
              :aria-label="s__('Modal|Close')"
              @click="emitCancel($event)"
            >
              <span aria-hidden="true">&times;</span>
            </button>
          </slot>
        </div>

        <div class="modal-body">
          <slot></slot>
        </div>

        <div class="modal-footer">
          <slot name="footer">
            <button
              type="button"
              class="btn js-modal-cancel-action"
              data-dismiss="modal"
              @click="emitCancel($event)"
            >
              {{ s__('Modal|Cancel') }}
            </button>
            <button
              type="button"
              class="btn js-modal-primary-action"
              :class="`btn-${footerPrimaryButtonVariant}`"
              data-dismiss="modal"
              @click="emitSubmit($event)"
            >
              {{ footerPrimaryButtonText }}
            </button>
          </slot>
        </div>
      </div>
    </div>
  </div>
</template>
