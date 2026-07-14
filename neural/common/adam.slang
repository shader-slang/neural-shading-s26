// SPDX-License-Identifier: Apache-2.0

public float adam_update(float primal, float grad, inout float mean, inout float variance, float learning_rate, int iteration)
{
    const float ADAM_BETA_1 = 0.9f;
    const float ADAM_BETA_2 = 0.999f;
    const float ADAM_EPSILON = 1e-8f;

    float p = isnan(primal) ? 0.0f : primal;
    float g = isnan(grad) ? 0.0f : grad;

    mean = lerp(g, mean, ADAM_BETA_1);
    variance = lerp(g * g, variance, ADAM_BETA_2);

    float m_hat = mean / (1.0f - pow(ADAM_BETA_1, iteration));
    float v_hat = variance / (1.0f - pow(ADAM_BETA_2, iteration));
    float step = learning_rate * m_hat / (sqrt(v_hat) + ADAM_EPSILON);

    float new_p = p - step;
    return !isnan(new_p) ? new_p : primal;
}

public void optimizer_step(inout half primal, inout half grad, inout float mean, inout float variance, float learning_rate, int iteration)
{
    half new_p = (half)adam_update(float(primal), float(grad), mean, variance, learning_rate, iteration);
    if (!isnan(new_p))
        primal = new_p;
    grad = (half)0.0f;
}

public void optimizer_step_float(inout float primal, inout float grad, inout float mean, inout float variance, float learning_rate, int iteration)
{
    primal = adam_update(primal, grad, mean, variance, learning_rate, iteration);
    grad = 0.0f;
}

